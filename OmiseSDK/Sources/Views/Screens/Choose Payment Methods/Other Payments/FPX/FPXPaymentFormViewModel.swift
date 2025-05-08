import Foundation

protocol FPXPaymentFormControllerDelegate: AnyObject {
    func fpxDidCompleteWith(email: String?, completion: @escaping () -> Void)
}

class FPXPaymentFormViewModel: FPXPaymentFormViewModelProtocol {
    var input: FPXPaymentFormViewModelInput { self }
    var output: FPXPaymentFormViewModelOutput {self }
    
    weak var delegate: FPXPaymentFormControllerDelegate?
    
    private var loadingClosure: ParamClosure<Bool> = nil
    
    init() { /* Non-optional default empty implementation */ }
}

extension FPXPaymentFormViewModel: FPXPaymentFormViewModelInput {
    func viewWillAppear() {
        loadingClosure?(false)
    }
    
    func startPayment(email: String?) {
        loadingClosure?(true)
        delegate?.fpxDidCompleteWith(email: email) { [weak self] in
            guard let self = self else { return }
            self.loadingClosure?(false)
        }
    }
    
    func set(loadingClosure: ParamClosure<Bool>) {
        self.loadingClosure = loadingClosure
    }
}

extension FPXPaymentFormViewModel: FPXPaymentFormViewModelOutput {
    var emailError: String {
        NSLocalizedString("econtext-info-form.email-name-field.invalid-data.error.text",
                          tableName: "Error",
                          bundle: .omiseSDK,
                          value: "Email is invalid",
                          comment: "Invalid email")
    }
}
