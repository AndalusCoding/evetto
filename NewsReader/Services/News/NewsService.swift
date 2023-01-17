import Foundation
import RxSwift
import Fakery

protocol NewsServiceType {
    func getTopHeadlines() -> Observable<[TopStoryHeadline]>
}

final class NewsService: NewsServiceType {
    
    func getTopHeadlines() -> Observable<[TopStoryHeadline]> {
        return Observable.just([
            .placeholder,
            .placeholder,
            .placeholder,
            .placeholder,
            .placeholder,
            .placeholder,
        ])
    }
    
}
