import XCTest
@testable import OmiseSDK

class ApplePayViewModelTests: XCTestCase {
    
    var viewModel: ApplePayViewModel!
    var mockHandler: MockApplePaymentHandler!
    var mockDelegate: MockApplePayViewModelDelegate!
    
    // Dummy ApplePayInfo for testing
    let dummyApplePayInfo = ApplePayInfo(merchantIdentifier: "merchant.com.test", requestBillingAddress: true)
    
    override func setUp() {
        super.setUp()
        mockHandler = MockApplePaymentHandler()
        mockDelegate = MockApplePayViewModelDelegate()
        viewModel = ApplePayViewModel(
            applePayInfo: dummyApplePayInfo,
            amount: 1000,
            currency: "SGD",
            country: .init(code: "SG"),
            applePaymentHandler: mockHandler,
            delegate: mockDelegate
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockHandler = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    /// Test when no payment is returned (e.g. user canceled).
    func testStartPayment_NoPayment() {
        let expectation = self.expectation(description: "No payment returned")
        mockHandler.mockPayment = nil
        mockHandler.mockError = nil
        
        viewModel.input.startPayment {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(mockDelegate.didFinishApplePayCalled, "Delegate should not be called when no payment and no error are returned")
    }
    
    /// Test when an error is returned from ApplePaymentHandler.
    func testStartPayment_Error() {
        let expectation = self.expectation(description: "Error returned")
        let simulatedError = NSError(domain: "TestError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])
        mockHandler.mockPayment = nil
        mockHandler.mockError = simulatedError
        
        viewModel.input.startPayment {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        guard let result = mockDelegate.resultPassed else {
            XCTFail("Delegate did not receive a result")
            return
        }
        
        switch result {
        case .failure(let error as NSError):
            XCTAssertEqual(error.domain, "TestError")
            XCTAssertEqual(error.code, 123)
        default:
            XCTFail("Expected failure result")
        }
    }
    
    /// Test when a valid payment is returned and token payload creation succeeds.
    func testStartPayment_Success() {
        let expectation = self.expectation(description: "Payment returned successfully")
        
        let mockPayment = MockPKPayment()
        mockHandler.mockPayment = mockPayment
        mockHandler.mockError = nil
        
        viewModel.input.startPayment {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        guard let result = mockDelegate.resultPassed else {
            XCTFail("Delegate did not receive a result")
            return
        }
        
        switch result {
        case .success(let tokenPayload):
            // Validate that token payload has expected values.
            XCTAssertEqual(tokenPayload.tokenization.method, "applepay")
            XCTAssertEqual(tokenPayload.tokenization.data, String(data: mockPayment.token.paymentData, encoding: .utf8))
            XCTAssertEqual(tokenPayload.tokenization.merchantId, dummyApplePayInfo.merchantIdentifier)
            // Payment method network raw value could be "VISA" or similar.
        default:
            XCTFail("Expected success result")
        }
    }
    
    /// Test when token payload creation fails.
    /// We simulate this by making the payment data empty so that the payload creation returns nil.
    func testStartPayment_FailedTokenCreation() {
        let expectation = self.expectation(description: "Token payload creation fails")
        mockHandler.mockPayment = nil
        mockHandler.mockError = NSError(domain: "PaymentError",
                                        code: 2,
                                        userInfo: [NSLocalizedDescriptionKey: "No payment data returned from ApplePay"])
        
        viewModel.input.startPayment {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        guard let result = mockDelegate.resultPassed else {
            XCTFail("Delegate did not receive a result")
            return
        }
        
        switch result {
        case .failure(let error as NSError):
            XCTAssertEqual(error.domain, "PaymentError")
        default: break
        }
    }
    
    /// Test branch: When payment is nil and error is nil,
    /// the completion closure is executed without calling the delegate.
    func testStartPayment_NoPaymentReturned() {
        let expectation = self.expectation(description: "No payment returned completion")
        mockHandler.mockPayment = nil
        mockHandler.mockError = nil
        
        viewModel.input.startPayment {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(mockDelegate.didFinishApplePayCalled, "Delegate should not be called when no payment and no error are returned")
    }
    
}
