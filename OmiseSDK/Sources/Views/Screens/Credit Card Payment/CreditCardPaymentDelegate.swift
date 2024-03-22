import Foundation

protocol CreditCardPaymentDelegate: AnyObject {
    func didSelectCardPayment(_ card: CreateTokenPayload.Card, completion: @escaping () -> Void)
    func didCancelCardPayment()
}
