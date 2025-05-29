import Foundation

protocol FPXPaymentFormViewModelProtocol {
    var input: FPXPaymentFormViewModelInput { get }
    var output: FPXPaymentFormViewModelOutput { get }
}

protocol FPXPaymentFormViewModelInput {
    func startPayment(email: String?)
    func set(loadingClosure: ParamClosure<Bool>)
    func viewWillAppear()
}

protocol FPXPaymentFormViewModelOutput {
    var emailError: String { get }
}
