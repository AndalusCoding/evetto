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
    let nextPageLoadingTrigger = PublishRelay<Void>()
    
    private let service: AdsServiceType
    
    init(
        service: AdsServiceType
    ) {
        self.service = service
        
        var page = 1
        
        ads = nextPageLoadingTrigger
            .flatMap { () -> Single<[Ad]> in
                service.getAdsList(page: page, limit: PAGE_LIMIT)
            }
            .do(onNext: { _ in
                page += 1
            })
            .map { ads -> [AdsSection] in
                return [
                    AdsSection(
                        identity: UUID().uuidString,
                        items: ads.map(AdListItem.ad)
                    )
                ]
            }
            .asDriver(onErrorJustReturn: [])
            .startWith([AdsSection(identity: UUID().uuidString, items: [.activityIndicator])])
            .scan([], accumulator: +)
    }
    
}
