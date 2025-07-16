import XCTest
import UIKit
@testable import OmiseSDK

class ChoosePaymentCoordinatorTests: XCTestCase {
    
    var sut: ChoosePaymentCoordinator!
    var mockClient: MockClient!
    var mockChoosePaymentMethodDelegate: MockChoosePaymentMethodDelegate!
    var mockNavigationController: MockNavigationController!
    var mockViewController: UIViewController!
    
    override func setUp() {
        super.setUp()
        mockClient = MockClient()
        mockChoosePaymentMethodDelegate = MockChoosePaymentMethodDelegate()
        mockNavigationController = MockNavigationController()
        // Create the coordinator with mock dependencies
        sut = ChoosePaymentCoordinator(
            client: mockClient,
            amount: 999,
            currency: "USD",
            currentCountry: nil,
            applePayInfo: ApplePayInfo(merchantIdentifier: "", requestBillingAddress: true),
            handleErrors: true
        )
        
        sut.choosePaymentMethodDelegate = mockChoosePaymentMethodDelegate
        
        mockViewController = UIViewController()
        mockNavigationController = MockNavigationController(rootViewController: mockViewController)
        
        sut.rootViewController = mockViewController
    }
    
    override func tearDown() {
        sut = nil
        mockClient = nil
        mockChoosePaymentMethodDelegate = nil
        super.tearDown()
    }
    
    func test_process_whiteLabelPayment() throws {
        let expectation = XCTestExpectation(description: "Did Process Payment for White Label Installment")
        let token: Token = try sampleFromJSONBy(.token)
        let source: Source = try sampleFromJSONBy(.source(type: .installmentBAY))
        
        let card = CreateTokenPayload.Card(name: "John Doe",
                                           number: "4242424242424242",
                                           expirationMonth: 12,
                                           expirationYear: 2020,
                                           securityCode: "123")
        
        let installment = Source.Payment.Installment(installmentTerm: 3,
                                                     zeroInterestInstallments: true,
                                                     sourceType: .installmentBAY)
        sut.didSelectCardPayment(
            paymentType: .whiteLabelInstallment(payment: .installment(installment)),
            card: card) { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls[0], .choosePaymentMethodDidComplete)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.token, token)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.source, source)
    }
    
    func test_process_whiteLabelPayment_Failure() throws {
        let expectation = XCTestExpectation(description: "Did Process Payment for White Label Installment")
        let card = CreateTokenPayload.Card(name: "John Doe",
                                           number: "4242424242424242",
                                           expirationMonth: 12,
                                           expirationYear: 2020,
                                           securityCode: "123")
        
        let installment = Source.Payment.Installment(installmentTerm: 3,
                                                     zeroInterestInstallments: true,
                                                     sourceType: .installmentBAY)
        
        mockClient.shouldShowError = true
        sut.didSelectCardPayment(
            paymentType: .whiteLabelInstallment(payment: .installment(installment)),
            card: card) { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 0)
        XCTAssertNil(mockChoosePaymentMethodDelegate.token)
        XCTAssertNil(mockChoosePaymentMethodDelegate.source)
    }
    
    func test_didSelectCardPayment() throws {
        let expectation = XCTestExpectation(description: "Did Select Card Payment")
        let token: Token = try sampleFromJSONBy(.token)
        
        let card = CreateTokenPayload.Card(name: "John Doe",
                                           number: "4242424242424242",
                                           expirationMonth: 12,
                                           expirationYear: 2020,
                                           securityCode: "123")
        sut.didSelectCardPayment(
            paymentType: .card,
            card: card) { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls[0], .choosePaymentMethodDidComplete)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.token, token)
    }
    
    func test_didCancelPayment() {
        sut.didCancelCardPayment()
        
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls[0], .choosePaymentMethodDidCancel)
        XCTAssertNil(mockChoosePaymentMethodDelegate.token)
    }
    
    func test_didSelectSourcePayment() throws {
        let expectation = XCTestExpectation(description: "Did Select Source Payment")
        let source: Source = try sampleFromJSONBy(.source(type: .grabPay))
        sut.didSelectSourcePayment(.sourceType(.grabPay)) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls[0], .choosePaymentMethodDidComplete)
        XCTAssertNil(mockChoosePaymentMethodDelegate.token)
        XCTAssertNotNil(mockChoosePaymentMethodDelegate.source)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.source, source)
    }
    
    func test_didSelectSourcePayment_WhiteLabel() throws {
        let payment: Source.Payment = .installment(
            .init(installmentTerm: 6,
                  zeroInterestInstallments: false,
                  sourceType: .installmentWhiteLabelTTB)
        )
        
        sut.didSelectSourcePayment(payment) {
            /* Non-optional default empty implementation */
        }
        
        XCTAssertTrue(mockNavigationController.pushedViewController is CreditCardPaymentController)
    }
    
    func test_processError_OmiseError() {
        let reason: OmiseError.APIErrorCode.InvalidCardReason = .invalidCardNumber
        let apiCode: OmiseError.APIErrorCode = .invalidCard([reason])
        
        let error = OmiseError.api(code: apiCode,
                                   message: "Card number is wrong",
                                   location: "number")
        
        sut.processError(error)
        
        XCTAssertEqual(sut.errorView.title, error.localizedDescription)
        XCTAssertEqual(sut.errorView.subtitle, error.recoverySuggestion)
    }
    
    func test_processError_LocalizedError() {
        class MockLocalizedError: LocalizedError {
            var errorDescription: String? { "Something went wrong" }
            var recoverySuggestion: String? { "Try again later." }
        }
        
        let error = MockLocalizedError()
        
        sut.processError(error)
        
        XCTAssertEqual(sut.errorView.title, error.localizedDescription)
        XCTAssertEqual(sut.errorView.subtitle, error.recoverySuggestion)
    }
    
    func test_processError_delegation() {
        sut = ChoosePaymentCoordinator(
            client: mockClient,
            amount: 999,
            currency: "USD",
            currentCountry: nil,
            applePayInfo: ApplePayInfo(merchantIdentifier: "", requestBillingAddress: true),
            handleErrors: false
        )
        sut.choosePaymentMethodDelegate = mockChoosePaymentMethodDelegate
        let error = NSError(domain: "TestError",
                            code: 123,
                            userInfo: [NSLocalizedDescriptionKey: "Test error"])
        sut.processError(error)
        
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls[0], .choosePaymentMethodDidComplete)
        XCTAssertNil(mockChoosePaymentMethodDelegate.token)
        XCTAssertNil(mockChoosePaymentMethodDelegate.source)
        XCTAssertNotNil(mockChoosePaymentMethodDelegate.error)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.error?.localizedDescription, error.localizedDescription)
    }
    
    func test_navigationController() {
        let error = NSError(domain: "TestError",
                            code: 123,
                            userInfo: [NSLocalizedDescriptionKey: "Test error"])
        sut.processError(error)
        
        let vc = UIViewController()
        sut.navigationController(mockNavigationController, willShow: vc, animated: false)
        
        XCTAssertNil(sut.errorView.superview)
        XCTAssertFalse(mockNavigationController.view.subviews.contains(sut.errorView))
    }
    
    func test_navigationController_Animated() {
        let duration = TimeInterval(UINavigationController.hideShowBarDuration)
        let exp = expectation(description: "wait for hide/show-bar animation")
        
        let error = NSError(domain: "TestError",
                            code: 123,
                            userInfo: [NSLocalizedDescriptionKey: "Test error"])
        sut.processError(error)
        
        let vc = UIViewController()
        sut.navigationController(mockNavigationController, willShow: vc, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: duration + 0.5)
        
        XCTAssertNil(sut.errorView.superview)
        XCTAssertFalse(mockNavigationController.view.subviews.contains(sut.errorView))
    }
}
