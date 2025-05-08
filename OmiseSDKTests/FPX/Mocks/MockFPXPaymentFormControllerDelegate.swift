@testable import OmiseSDK

class MockFPXPaymentFormControllerDelegate: FPXPaymentFormControllerDelegate {
    var didCompleteCalled = false
    var completionWasCalled = false
    
    func fpxDidCompleteWith(email: String?, completion: @escaping () -> Void) {
        didCompleteCalled = true
        completion()
        completionWasCalled = true
    }
}
