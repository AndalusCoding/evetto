import Foundation
import CoreLocation

public struct Coordinate: Decodable, Hashable {
    let latitude: Double
    let longitude: Double
}

extension Coordinate {
    var coordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}
