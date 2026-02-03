import Foundation
import PassKit
@testable import OmiseSDK

class MockApplePaymentHandler: ApplePaymentHandlerType {
    // Simulated values
    var mockPayment: PKPayment?
    var mockError: Error?
    var amountToApplePayRequest: NSDecimalNumber = .zero
    
    func createPKPaymentRequest(
        with amount: NSDecimalNumber,
        currency: String,
        country: Country?,
        requiredBillingAddress: Bool,
        merchantId: String
    ) -> PKPaymentRequest {
        amountToApplePayRequest = amount
        return PKPaymentRequest()
    }
    
    func createPaymentAuthViewController(from request: PKPaymentRequest) -> PKPaymentAuthorizationController {
        PKPaymentAuthorizationController(paymentRequest: request)
    }
    
    func present(
        paymentController paymentAuthController: PKPaymentAuthorizationController,
        completion: @escaping (PKPayment?, (any Error)?) -> Void
    ) {
        completion(mockPayment, mockError)
    }
}
