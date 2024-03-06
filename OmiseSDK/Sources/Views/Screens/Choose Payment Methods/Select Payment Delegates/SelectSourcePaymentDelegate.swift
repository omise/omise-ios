import Foundation

protocol SelectSourcePaymentDelegate: AnyObject {
    func didSelectSourcePayment(_ payment: Source.Payment, completion: @escaping () -> Void)
}
