import Foundation
import XCoordinator

struct RouteTrigger<RouteType: Route> {
    private var router: UnownedRouter<RouteType>?
    
    func trigger(_ route: RouteType) {
        router?.trigger(route)
    }
    
    init(unownedRouter: UnownedRouter<RouteType>) {
        self.router = unownedRouter
    }
    
    private init() {}
    
    static var empty: RouteTrigger<RouteType> {
        return RouteTrigger()
    }
}
