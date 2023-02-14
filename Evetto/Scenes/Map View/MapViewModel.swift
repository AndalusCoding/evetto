import Foundation
import CoreLocation
import MapKit

private let coordinateSpan = MKCoordinateSpan(
    latitudeDelta: 0.2,
    longitudeDelta: 0.2
)

final class MapViewModel: ObservableObject {
    
    private let locationManager = CLLocationManager()
    
    @Published var coordinateRegion: MKCoordinateRegion
    
    struct Annotation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
    
    @Published var annotations: [Annotation] = []
    
    init(
        coordinate: Coordinate
    ) {
        self.coordinateRegion = MKCoordinateRegion(
            center: coordinate.coordinate2D,
            span: coordinateSpan
        )
        annotations = [
            Annotation(coordinate: coordinate.coordinate2D)
        ]
    }
    
    func requestUserLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func showUsersLocation() {
        guard let location = locationManager.location else {
            return
        }
        coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: coordinateSpan
        )
    }
    
    static var placeholder: MapViewModel {
        MapViewModel(
            coordinate: Coordinate(
                latitude: 41,
                longitude: 28.9
            )
        )
    }
    
}
