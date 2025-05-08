@testable import OmiseSDK

class MockFPXPaymentFormViewModel: FPXPaymentFormViewModelProtocol,
                                   FPXPaymentFormViewModelInput,
                                   FPXPaymentFormViewModelOutput {
    var input: FPXPaymentFormViewModelInput { self }
    var output: FPXPaymentFormViewModelOutput { self }
    
    private(set) var startPaymentCalled = false
    private(set) var capturedEmail: String?
    
    private(set) var loadingClosure: ParamClosure<Bool> = nil
    
    func viewWillAppear() {
        loadingClosure?(false)
    }
    
    func startPayment(email: String?) {
        startPaymentCalled = true
        capturedEmail = email
    }
    
    func set(loadingClosure: ParamClosure<Bool>) {
        self.loadingClosure = loadingClosure
    }
    
    var emailError: String { "Email error" }
}
