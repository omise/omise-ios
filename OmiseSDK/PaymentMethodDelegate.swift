import Foundation

protocol PaymentMethodDelegate: AnyObject {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod)
    func didCancelPayment()
}

