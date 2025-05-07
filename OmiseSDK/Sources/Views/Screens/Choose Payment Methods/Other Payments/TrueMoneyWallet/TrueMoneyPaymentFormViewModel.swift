import Foundation

class TrueMoneyPaymentFormViewModel: TrueMoneyPaymentFormProtocol {
    var input: TrueMoneyPaymentFormViewModelInput { self }
    var output: TrueMoneyPaymentFormViewModelOutput {self }
    
    weak var delegate: SelectSourcePaymentDelegate?
    
    private var loadingClosure: ParamClosure<Bool> = nil
    
    init() { }
}

extension TrueMoneyPaymentFormViewModel: TrueMoneyPaymentFormViewModelInput {
    func startPayment(for phone: String) {
        let payload = Source.Payment.TrueMoneyWallet(phoneNumber: phone)
        
        loadingClosure?(true)
        delegate?.didSelectSourcePayment(.trueMoneyWallet(payload)) { [weak self] in
            guard let self = self else { return }
            self.loadingClosure?(false)
        }
    }
    
    func set(loadingClosure: ParamClosure<Bool>) {
        self.loadingClosure = loadingClosure
    }
}

extension TrueMoneyPaymentFormViewModel: TrueMoneyPaymentFormViewModelOutput {
    var phoneError: String {
        NSLocalizedString("econtext-info-form.phone-number-field.invalid-data.error.text",
                          tableName: "Error",
                          bundle: .omiseSDK,
                          value: "Phone number is invalid",
                          comment: "Invalid phone number")
    }
}
