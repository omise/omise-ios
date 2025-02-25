import XCTest
import PassKit
@testable import OmiseSDK

class ApplePaymentHandlerTests: XCTestCase {
    
    var applePaymentHandler: ApplePaymentHandler!
    var mockPaymentController: MockPaymentAuthorizationController!
    var mockPaymentRequest: PKPaymentRequest!
    
    override func setUp() {
        super.setUp()
        applePaymentHandler = ApplePaymentHandler()
        mockPaymentController = MockPaymentAuthorizationController()
        mockPaymentRequest = PKPaymentRequest()
        applePaymentHandler.paymentController = mockPaymentController
    }
    
    override func tearDown() {
        applePaymentHandler = nil
        mockPaymentController = nil
        mockPaymentRequest = nil
        super.tearDown()
    }
    
    // MARK: - Fixed Tests
    
    func testPaymentAuthorizationDidFinish() {
        let expectation = self.expectation(description: "Payment Authorization Did Finish")
        let request = applePaymentHandler.createPKPaymentRequest(
            with: NSDecimalNumber(string: "10.00"),
            currency: "USD",
            country: Country(code: "US"),
            requiredBillingAddress: true,
            merchantId: "merchant.com.yourApp"
        )
        let controller = applePaymentHandler.createPaymentAuthViewController(from: request)
        applePaymentHandler.present(paymentController: controller) { payment, error in
            XCTAssertNil(payment)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        applePaymentHandler.paymentController = mockPaymentController
        
        // Trigger the delegate method directly using our mock controller
        applePaymentHandler.paymentAuthorizationControllerDidFinish(controller)
        
        // Wait for the completion handler
        waitForExpectations(timeout: 1, handler: nil)
        
        // Verify the dismissal
        XCTAssertTrue(mockPaymentController.dismissSheetCalled, "Dismiss should be called when controller finishes")
    }
    
    func testCountryNil() {
        let expectation = self.expectation(description: "Payment Authorization Did Finish")
        let request = applePaymentHandler.createPKPaymentRequest(
            with: NSDecimalNumber(string: "10.00"),
            currency: "",
            country: nil,
            requiredBillingAddress: true,
            merchantId: "merchant.com.yourApp"
        )
        let controller = applePaymentHandler.createPaymentAuthViewController(from: request)
        applePaymentHandler.present(paymentController: controller) { payment, error in
            XCTAssertNil(payment)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        applePaymentHandler.paymentController = mockPaymentController
        
        // Trigger the delegate method directly using our mock controller
        applePaymentHandler.paymentAuthorizationControllerDidFinish(controller)
        
        // Wait for the completion handler
        waitForExpectations(timeout: 1, handler: nil)
        
        // Verify the dismissal
        XCTAssertTrue(mockPaymentController.dismissSheetCalled, "Dismiss should be called when controller finishes")
    }
}
