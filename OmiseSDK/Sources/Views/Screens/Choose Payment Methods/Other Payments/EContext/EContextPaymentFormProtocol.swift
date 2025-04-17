import Foundation

protocol EContextPaymentFormViewModelProtocol {
    var input: EContextPaymentFormViewModelInput { get }
    var output: EContextPaymentFormViewModelOutput { get }
}

protocol EContextPaymentFormViewModelInput {
    func startPayment(name: String, email: String, phone: String)
    func set(loadingClosure: ParamClosure<Bool>)
}

protocol EContextPaymentFormViewModelOutput {
    var nameError: String { get }
    var emailError: String { get }
    var phoneError: String { get }
}
