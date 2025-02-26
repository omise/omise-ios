import Foundation
@testable import OmiseSDK

class MockSelectPaymentMethodDelegate: SelectPaymentMethodDelegate {
    enum Call {
        case didSelectPaymentMethod
        case didCancelPayment
    }
    
    var calls: [Call] = []
    
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod, completion: @escaping () -> Void) {
        calls.append(.didSelectPaymentMethod)
    }
    
    func didCancelPayment() {
        calls.append(.didCancelPayment)
    }
}
