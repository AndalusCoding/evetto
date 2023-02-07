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
    
    @Published private(set) var changingFavoriteState = false
    @Published private(set) var isFavorite = false
    
    private let dateFormatter = DateFormatter.dayAndTimeFormatter
    private let priceNumberFormatter = NumberFormatter.priceNumberFormatter
    private var disposeBag = DisposeBag()
    
    private let toggleFavorite: (Bool) -> Single<Void>
    private let routeTrigger: RouteTrigger<AdsRoute>
    
    init(
        adDetails: Observable<Ad>,
        toggleFavorite: @escaping (Bool) -> Single<Void>,
        routeTrigger: RouteTrigger<AdsRoute>
    ) {
        self.routeTrigger = routeTrigger
        self.toggleFavorite = toggleFavorite
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
        isFavorite = ad.isFavorite ?? false
    }
    
    func contactSeller(_ contact: Contact) {
        routeTrigger.trigger(.contact(contact))
    }
    
    func toggleFavoriteState() {
        changingFavoriteState = true
        let newFlag = !isFavorite
        toggleFavorite(newFlag)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] in
                self.isFavorite = newFlag
                self.changingFavoriteState = false
            })
            .disposed(by: disposeBag)
    }
    
    static var placeholder: AdDetailsViewModel {
        AdDetailsViewModel(
            adDetails: .just(.placeholder(currency: .TRY)),
            toggleFavorite: { _ in Single.just(()).delay(.seconds(3), scheduler: MainScheduler.instance) },
            routeTrigger: .empty
        )
    }
    
}
