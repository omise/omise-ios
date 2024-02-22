import Foundation

protocol CreditCardPaymentDelegate: AnyObject {
    func didSelectCardPayment(_ card: CreateTokenPayload.Card)
    func didCancelCardPayment()
}
