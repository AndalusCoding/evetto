import XCTest
import RxSwift
import RxCocoa
import RxBlocking
import RxTest
@testable import Evetto

final class AdDetailsViewModelTests: XCTestCase {
    
    var sut: AdDetailsViewModel!
    let adDetailsObservable = PublishSubject<Ad>()
    
    override func setUp() async throws {
        sut = AdDetailsViewModel(
            adDetails: adDetailsObservable.asObservable(),
            routeTrigger: .empty
        )
    }
    
    func testIfDidLoadDataSetToTrueAfterLoading() async throws {
        adDetailsObservable.onNext(Ad.placeholder(currency: .TRY))
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssert(sut.didLoadData)
    }
    
    func testIfContactsListIsNotEmpty() async throws {
        adDetailsObservable.onNext(Ad.placeholder(currency: .TRY))
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssert(sut.contacts.isEmpty == false, "Список контактов не должен быть пустым.")
    }
    
    func testIfContactsArrayContainsCorrectData() async throws {
        adDetailsObservable.onNext(Ad.placeholder(currency: .TRY))
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.contacts[0].value, "+79190000000")
    }
    
    func testIfTitleIsCorrect() async throws {
        adDetailsObservable.onNext(Ad.placeholder(currency: .TRY))
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.title, "Вилла в Текирдаге")
    }

}
