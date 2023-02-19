import Foundation
import RxSwift
import Fakery

struct AdsSorting: Hashable {
    enum Sort: String, Hashable, CaseIterable {
        case createdAt, updatedAt, price
        
        var title: String {
            switch self {
            case .createdAt: return "Дата создания"
            case .updatedAt: return "Дата изменения"
            case .price: return "Цена"
            }
        }
    }
    
    let sort: Sort
    let sortAscending: Bool
}

protocol AdsServiceType {
    func getAdsList(
        page: Int,
        limit: Int,
        text: String?,
        sort: AdsSorting?
    ) -> Single<[Ad]>
    
    func getAdDetails(_ id: UUID) -> Single<Ad>

    func toggleFavoriteState(adId: UUID, flag: Bool) -> Single<Void>
}

final class AdsService: AdsServiceType {
    
    let baseURL = URL(string: "https://api.evetto.app/v1/ads/")!
    
    func getAdsList(
        page: Int,
        limit: Int,
        text: String?,
        sort: AdsSorting?
    ) -> Single<[Ad]> {
        assert(Thread.isMainThread)
        var urlQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(limit)"),
        ]
        
        if let text {
            urlQueryItems.append(URLQueryItem(name: "text", value: text))
        }
        
        if let sort {
            urlQueryItems.append(contentsOf: [
                URLQueryItem(name: "sort", value: sort.sort.rawValue),
                URLQueryItem(name: "sortAscending", value: "\(sort.sortAscending)"),
            ])
        }
        
        guard var urlComponents = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: true
        ) else {
            fatalError()
        }
        
        urlComponents.queryItems = urlQueryItems
        
        guard let url = urlComponents.url else {
            fatalError()
        }
        
        let request = URLRequest(url: url)
        
        struct Response: Decodable {
            let data: [Ad]
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return URLSession.shared
            .rx
            .data(request: request)
            .map { data in
                try! decoder.decode(Response.self, from: data)
            }
            .map(\.data)
            .asSingle()
    }
    
    func getAdDetails(_ id: UUID) -> Single<Ad> {
        assert(Thread.isMainThread)
        var request = URLRequest(
            url: URL(string: "https://api.evetto.app/v1/ads/\(id.uuidString)")!
        )
        request.setValue(ProcessInfo.processInfo.environment["TOKEN"] ?? "", forHTTPHeaderField: "Authorization")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return URLSession.shared
            .rx
            .data(request: request)
            .map { data in
                try! decoder.decode(Ad.self, from: data)
            }
            .asSingle()
    }
    
    func toggleFavoriteState(
        adId: UUID,
        flag: Bool
    ) -> Single<Void> {
        let url = URL(string: "https://api.evetto.app/v1/ads/favorites/\(adId.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = flag ? "POST" : "DELETE"
        request.setValue(ProcessInfo.processInfo.environment["TOKEN"] ?? "", forHTTPHeaderField: "Authorization")
        return URLSession.shared
            .rx
            .data(request: request)
            .map { _ in }
            .asSingle()
    }
    
}
