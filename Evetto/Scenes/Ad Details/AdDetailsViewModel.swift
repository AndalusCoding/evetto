import Foundation
import RxSwift

final class AdDetailsViewModel: ObservableObject {
    
    @Published var didLoadData = false
    @Published var shareURL = URL(string: "https://google.com")!
    @Published var imageURLs: [URL] = []
    @Published var title = ""
    @Published var location: String?
    @Published var price = ""
    @Published var category = ""
    @Published var date = ""
    @Published var numberOfViews = ""
    @Published var descriptionText: String?
    @Published var sellerName = ""
    @Published var contacts: [Contact] = []
    
    private let dateFormatter = DateFormatter.dayAndTimeFormatter
    private let priceNumberFormatter = NumberFormatter.priceNumberFormatter
    private var disposeBag = DisposeBag()
    private let routeTrigger: RouteTrigger<AdsRoute>
    
    init(
        adDetails: Observable<Ad>,
        routeTrigger: RouteTrigger<AdsRoute>
    ) {
        self.routeTrigger = routeTrigger
        adDetails
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [unowned self] ad in
                    assert(Thread.isMainThread)
                    self.update(from: ad)
                },
                onError: { error in
                    assert(Thread.isMainThread)
                    print(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func update(from ad: Ad) {
        shareURL = ad.adsURL
        imageURLs = (ad.attachments?.map(\.link) ?? [])
        title = ad.title
        descriptionText = ad.description
        location = ad.location?.area ?? ""
        if let price = ad.price {
            priceNumberFormatter.currencyCode = price.currency.rawValue
            priceNumberFormatter.currencySymbol = price.currency.currencySymbol
            self.price = priceNumberFormatter.string(for: price.amount) ?? "\(price.amount)"
        } else {
            price = "Цена не указана"
        }
        category = ad.category?.title ?? ""
        date = dateFormatter.string(from: ad.createdAt)
        contacts = ad.contacts ?? []
        didLoadData = true
    }
    
    func contactSeller(_ contact: Contact) {
        routeTrigger.trigger(.contact(contact))
    }
    
    static var placeholder: AdDetailsViewModel {
        AdDetailsViewModel(
            adDetails: .just(.placeholder(currency: .TRY)),
            routeTrigger: .empty
        )
    }
    
}
