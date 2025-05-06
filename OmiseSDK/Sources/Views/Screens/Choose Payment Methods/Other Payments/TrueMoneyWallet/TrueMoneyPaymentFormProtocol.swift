import Foundation

protocol TrueMoneyPaymentFormProtocol {
    var input: TrueMoneyPaymentFormViewModelInput { get }
    var output: TrueMoneyPaymentFormViewModelOutput { get }
}

protocol TrueMoneyPaymentFormViewModelInput {
    func startPayment(for phone: String)
    func set(loadingClosure: ParamClosure<Bool>)
}

protocol TrueMoneyPaymentFormViewModelOutput {
    var phoneError: String { get }
}
