import Foundation
import Fakery
import RxDataSources

let faker = Faker(locale: "ru")

struct Ad: Decodable {
    struct Category: Decodable {
        let title: String
        
        static var placeholder: Category {
            Category(
                title: faker.lorem.word()
            )
        }
    }
    
    struct Location: Decodable {
        let area: String
        let district: String?
        
        static var placeholder: Location {
            Location(area: "Istanbul", district: "Fatih")
        }
    }

    struct Price: Decodable {
        enum Currency: String, Decodable {
            case TRY, USD, RUB, EUR
        }
        
        let currency: Currency
        let amount: Double
    }
    
    let id: UUID
    let title: String
    let description: String
    var category: Category?
    let location: Location?
    let previewImageURL: URL?
    let createdAt: Date
    let price: Price?
    
    static var placeholder: Ad {
        Ad(
            id: UUID(),
            title: faker.lorem.words().capitalized,
            description: faker.lorem.paragraphs(amount: 2),
            category: .placeholder,
            location: .placeholder,
            previewImageURL: nil,
            createdAt: Date(),
            price: nil
        )
    }
}

extension Ad: IdentifiableType, Equatable {
    static func == (lhs: Ad, rhs: Ad) -> Bool {
        lhs.title == rhs.title
    }
    
    var identity: String {
        id.uuidString
    }
}
