import XCTest
@testable import OmiseSDK

class MockCreditCardDelegate: CreditCardPaymentDelegate {
    var didCancelFormCalled = false
    var didSelectCardPaymentCalled = false
    var receivedPaymentType: CreditCardPaymentOption?
    var receivedCard: CreateTokenPayload.Card?
    var completionCalled = false
    
    func didCancelCardPayment() {
        didCancelFormCalled = true
    }
    
    func didSelectCardPayment(
        paymentType: CreditCardPaymentOption,
        card: CreateTokenPayload.Card,
        completion: @escaping () -> Void
    ) {
        didSelectCardPaymentCalled = true
        receivedPaymentType = paymentType
        receivedCard = card
        // Simulate async completion
        completion()
        completionCalled = true
    }
}
