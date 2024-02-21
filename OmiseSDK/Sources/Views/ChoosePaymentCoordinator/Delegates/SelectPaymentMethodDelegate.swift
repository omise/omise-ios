import Foundation

protocol SelectPaymentMethodDelegate: AnyObject {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod)
    func didCancelPayment()
}
