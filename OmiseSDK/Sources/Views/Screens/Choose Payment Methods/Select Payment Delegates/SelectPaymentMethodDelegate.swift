import Foundation

protocol SelectPaymentMethodDelegate: AnyObject {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod, completion: @escaping () -> Void)
    func didCancelPayment()
}
