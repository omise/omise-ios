@testable import OmiseSDK

class MockTrueMoneyFormViewModel: TrueMoneyPaymentFormProtocol,
                                  TrueMoneyPaymentFormViewModelInput,
                                  TrueMoneyPaymentFormViewModelOutput {
    var input: TrueMoneyPaymentFormViewModelInput { self }
    var output: TrueMoneyPaymentFormViewModelOutput { self }
    
    private(set) var startPaymentCalled = false
    private(set) var capturedPhone: String?
    
    private(set) var loadingClosure: ParamClosure<Bool> = nil
    
    func startPayment(for phone: String) {
        startPaymentCalled = true
        capturedPhone = phone
    }
    
    func set(loadingClosure: ParamClosure<Bool>) {
        self.loadingClosure = loadingClosure
    }
    
    var phoneError: String { "Phone error" }
}
