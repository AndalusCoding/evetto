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
    
    let id: UUID
    let title: String
    let description: String
    var category: Category?
    
    static var placeholder: Ad {
        Ad(
            id: UUID(),
            title: faker.lorem.words().capitalized,
            description: faker.lorem.paragraphs(amount: 2),
            category: .placeholder
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
