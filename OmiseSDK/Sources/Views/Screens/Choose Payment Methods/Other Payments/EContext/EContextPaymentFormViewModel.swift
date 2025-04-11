import Foundation

class EContextPaymentFormViewModel: EContextPaymentFormViewModelProtocol {
    var input: EContextPaymentFormViewModelInput { self }
    var output: EContextPaymentFormViewModelOutput {self }
    
    weak var delegate: SelectSourcePaymentDelegate?
    
    private var loadingHandler: Handler<Bool> = nil
    
    init() { }
}

extension EContextPaymentFormViewModel: EContextPaymentFormViewModelInput {
    func startPayment(name: String, email: String, phone: String) {
        let eContextInformation = Source.Payment.EContext(name: name, email: email, phoneNumber: phone)
        let payment = Source.Payment.eContext(eContextInformation)
        
        loadingHandler?(true)
        delegate?.didSelectSourcePayment(payment) { [weak self] in
            guard let self = self else { return }
            self.loadingHandler?(false)
        }
    }
    
    func set(loadingHandler: Handler<Bool>) {
        self.loadingHandler = loadingHandler
    }
}

extension EContextPaymentFormViewModel: EContextPaymentFormViewModelOutput {
    var nameError: String {
        NSLocalizedString("econtext-info-form.full-name-field.invalid-data.error.text",
                          tableName: "Error",
                          bundle: .omiseSDK,
                          value: "Customer name is invalid",
                          comment: "Invalid name")
    }
    
    var emailError: String {
        NSLocalizedString("econtext-info-form.email-name-field.invalid-data.error.text",
                          tableName: "Error",
                          bundle: .omiseSDK,
                          value: "Email is invalid",
                          comment: "Invalid email")
    }
    
    var phoneeError: String {
        NSLocalizedString("econtext-info-form.phone-number-field.invalid-data.error.text",
                          tableName: "Error",
                          bundle: .omiseSDK,
                          value: "Phone number is invalid",
                          comment: "Invalid phone number")
    }
}
