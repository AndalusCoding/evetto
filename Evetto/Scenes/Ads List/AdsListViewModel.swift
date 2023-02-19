import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import XCoordinator

private let PAGE_LIMIT = 20

struct AdsSection {
    let identity: String
    var items: [AdsListViewModel.AdListItem]
}

extension AdsSection: AnimatableSectionModelType {
    init(original: AdsSection, items: [AdsListViewModel.AdListItem]) {
        self = original
        self.items = items
    }
}

final class AdsListViewModel {
    
    enum AdListItem: IdentifiableType, Equatable {
        case activityIndicator
        case ad(AdsListItemViewModel)

        var identity: String {
            switch self {
            case .activityIndicator: return "activityIndicator"
            case .ad(let ad): return ad.identity
            }
        }
    }
    
    let ads: Driver<[AdsSection]>
    let nextPageTrigger = PublishRelay<Void>()
    let reloadingTrigger = PublishRelay<Void>()
    let searchText = PublishRelay<String?>()
    let sorting = PublishRelay<AdsSorting.Sort?>()
    
    private let service: AdsServiceType
    private let routeTrigger: RouteTrigger<AdsRoute>
    
    init(
        service: AdsServiceType = appContext.adsService,
        routeTrigger: RouteTrigger<AdsRoute>
    ) {
        self.service = service
        
        let searchText = searchText
            .asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .share(replay: 1, scope: .forever)
        
        ads = AdsListViewModel.createAdsLoader(
            service: service,
            nextPageTrigger: nextPageTrigger.asObservable(),
            reloadTrigger: reloadingTrigger.asObservable(),
            searchText: searchText,
            sorting: sorting.asObservable().distinctUntilChanged()
        )
        self.routeTrigger = routeTrigger
    }
    
    func navigate(to ad: AdsListItemViewModel) {
        routeTrigger.trigger(.details(
            id: ad.id,
            title: ad.title,
            ad: ad.ad
        ))
    }
    
    static func createAdsLoader(
        service: AdsServiceType,
        nextPageTrigger: Observable<Void>,
        reloadTrigger: Observable<Void>,
        searchText: Observable<String?>,
        sorting: Observable<AdsSorting.Sort?>
    ) -> Driver<[AdsSection]> {
        var page = 0
        
        let dateFormatter = DateFormatter.dayAndTimeFormatter
        let numberFormatter = NumberFormatter.priceNumberFormatter
        
        return Observable
            .merge(
                nextPageTrigger.do(onNext: { page += 1 }),
                Observable
                    .merge(
                        reloadTrigger,
                        searchText.map { _ in },
                        sorting.map { _ in }
                    )
                    .do(onNext: { page = 1 })
            )
            .withLatestFrom(
                Observable.combineLatest(
                    searchText.startWith(nil),
                    sorting.startWith(nil)
                )
            )
            .flatMap { (text, sorting) -> Single<[Ad]> in
                service.getAdsList(
                    page: page,
                    limit: PAGE_LIMIT,
                    text: text,
                    sort: sorting.flatMap { AdsSorting(sort: $0, sortAscending: false) }
                )
            }
            .startWith([])
            .map { ads -> [AdsSection] in
                return [
                    AdsSection(
                        identity: UUID().uuidString,
                        items: ads.map { ad in
                            AdListItem.ad(AdsListItemViewModel(
                                ad: ad,
                                formatDate: dateFormatter.string,
                                priceFormatter: numberFormatter
                            ))
                        }
                    )
                ]
            }
            .asDriver(onErrorJustReturn: [])
            .scan([], accumulator: { old, new in
                let data: [AdsSection]
                if page == 1 {
                    data = new
                } else {
                    data = old.dropLast() + new
                }
                return data + [AdsSection(identity: UUID().uuidString, items: [.activityIndicator])]
            })
    }
    
}
