@testable import OmiseSDK

class MockEContextPaymentFormViewModel: EContextPaymentFormViewModelProtocol,
                                        EContextPaymentFormViewModelInput,
                                        EContextPaymentFormViewModelOutput {
    var input: EContextPaymentFormViewModelInput { self }
    var output: EContextPaymentFormViewModelOutput { self }
    
    private(set) var startPaymentCalled = false
    private(set) var capturedName: String?
    private(set) var capturedEmail: String?
    private(set) var capturedPhone: String?
    
    private(set) var loadingHandler: Handler<Bool> = nil
    
    func startPayment(name: String, email: String, phone: String) {
        startPaymentCalled = true
        capturedName = name
        capturedEmail = email
        capturedPhone = phone
    }
    
    func set(loadingHandler: Handler<Bool>) {
        self.loadingHandler = loadingHandler
    }
    
    var nameError: String { "Name error" }
    var emailError: String { "Email error" }
    var phoneeError: String { "Phone error" }
}
