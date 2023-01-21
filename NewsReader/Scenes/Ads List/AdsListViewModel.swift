import Foundation
import RxSwift
import RxCocoa
import RxDataSources

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
        case ad(Ad)

        
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
    
    private let service: AdsServiceType
    
    init(
        service: AdsServiceType = appContext.adsService
    ) {
        self.service = service
        ads = AdsListViewModel.createAdsLoader(
            service: service,
            nextPageTrigger: nextPageTrigger.asObservable(),
            reloadTrigger: reloadingTrigger.asObservable()
        )
    }
    
    static func createAdsLoader(
        service: AdsServiceType,
        nextPageTrigger: Observable<Void>,
        reloadTrigger: Observable<Void>
    ) -> Driver<[AdsSection]> {
        var page = 0
        
        return Observable
            .merge(
                nextPageTrigger.do(onNext: { page += 1 }),
                reloadTrigger.do(onNext: { page = 1 })
            )
            .flatMap { () -> Single<[Ad]> in
                service.getAdsList(page: page, limit: PAGE_LIMIT)
            }
            .startWith([])
            .map { ads -> [AdsSection] in
                return [
                    AdsSection(
                        identity: UUID().uuidString,
                        items: ads.map(AdListItem.ad)
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
