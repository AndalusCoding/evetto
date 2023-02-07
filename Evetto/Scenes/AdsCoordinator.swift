import UIKit
import SwiftUI
import XCoordinator
import RxSwift

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
                routeTrigger: .init(unownedRouter: unownedRouter)
            )
            let viewController = AdsListViewController(viewModel: viewModel)
            viewController.title = "Evetto"
            return .push(viewController)
            
        case .details(let adId, let title, let ad):
            let getAdDetailsObservable = service.getAdDetails(adId).asObservable()
            let adDetails: Observable<Ad>
            if let ad {
                adDetails = getAdDetailsObservable.startWith(ad)
            } else {
                adDetails = getAdDetailsObservable
            }
            let viewModel = AdDetailsViewModel(
                adDetails: adDetails,
                routeTrigger: .init(unownedRouter: unownedRouter)
            )
            let view = AdDetailsView(viewModel: viewModel)
            let viewController = AdDetailsViewController(rootView: view)
            viewController.title = title
            return .push(viewController)
            
        }
        
    }
    
}
