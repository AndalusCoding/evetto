import Foundation
import RxSwift

final class AdDetailsViewModel: ObservableObject {
    
    @Published var didLoadData = true
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
    
    init(
        adDetails: Observable<Ad>
    ) {
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
        didLoadData = ad.isPlaceholder != true
    }
    
    static var placeholder: AdDetailsViewModel {
        AdDetailsViewModel(
            adDetails: .just(.placeholder(currency: .TRY))
        )
    }
    
}
