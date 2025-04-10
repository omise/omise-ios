import Foundation
@testable import OmiseSDK

class MockSelectSourceTypeDelegate: SelectSourceTypeDelegate {
    var didSelectCalled = false
    var selectedSourceType: SourceType?
    var completionWasCalled = false
    
    func didSelectSourceType(_ sourceType: SourceType, completion: @escaping () -> Void) {
        didSelectCalled = true
        selectedSourceType = sourceType
        completion()
        completionWasCalled = true
    }
}

class MockSelectSourcePaymentDelegate: SelectSourcePaymentDelegate {
    var didSelectCalled = false
    var selectedPayment: Source.Payment?
    var completionWasCalled = false

    func didSelectSourcePayment(_ payment: Source.Payment, completion: @escaping () -> Void) {
        didSelectCalled = true
        selectedPayment = payment
        completion()
        completionWasCalled = true
    }
    
    func reset() {
        didSelectCalled = false
        selectedPayment = nil
        completionWasCalled = false
    }
}
