import UIKit
import SwiftUI
import XCoordinator
import RxSwift

typealias AdsRouteTrigger = (AdsRoute) -> Void

enum AdsRoute: Route {
    /// Vertical list of ads.
    case list
    /// Ad details.
    case details(id: UUID, title: String? = nil, ad: Ad? = nil)
}

/**
 Helps to navigate through ads related screens.
 */
final class AdsCoordinator: NavigationCoordinator<AdsRoute> {
    
    private let service: AdsServiceType
    
    init(
        rootViewController: RootViewController = .init(),
        service: AdsServiceType
    ) {
        self.service = service
        super.init(rootViewController: rootViewController)
        rootViewController.navigationBar.prefersLargeTitles = true
    }
    
    override func prepareTransition(
        for route: AdsRoute
    ) -> NavigationTransition {
        
        switch route {
            
        case .list:
            let viewModel = AdsListViewModel(
                service: service,
                routeTrigger: { [unowned self] route in
                    self.trigger(route)
                }
            )
            let viewController = AdsListViewController(viewModel: viewModel)
            viewController.title = "Evetto"
            return .push(viewController)
            
        case .details(let adId, let title, let ad):
            let adDetails = service
                .getAdDetails(adId)
                .asObservable()
                .startWith(ad ?? Ad.placeholder(currency: .TRY))
            let viewModel = AdDetailsViewModel(adDetails: adDetails)
            let view = AdDetailsView(viewModel: viewModel)
            let viewController = AdDetailsViewController(rootView: view)
            viewController.title = title
            return .push(viewController)
            
        }
        
    }
    
}
