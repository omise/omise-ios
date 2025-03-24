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
    
    func test_didSelectPaymentMethod() {
        sut.didSelectPaymentMethod(.sourceType(.applePay)) { }
        XCTAssertTrue(mockNavigationController.pushedViewController is ApplePayViewController)
    }
    
    func test_processPayment_applePay() throws {
        let expectation = XCTestExpectation(description: "Did Process Payment for ApplePay")
        let applePayPayload: CreateTokenApplePayPayload = try sampleFromJSONBy(.source(type: .applePay))
        let token: Token = try sampleFromJSONBy(.token)
        
        sut.didFinishApplePayWith(result: .success(applePayPayload)) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.calls[0], .choosePaymentMethodDidComplete)
        XCTAssertEqual(mockChoosePaymentMethodDelegate.token, token)
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
}
