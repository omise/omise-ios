import Foundation

protocol CreditCardPaymentDelegate: AnyObject {
    func didSelectCardPayment(paymentType: CreditCardPaymentOption, card: CreateTokenPayload.Card, completion: @escaping () -> Void)
    func didCancelCardPayment()
}
