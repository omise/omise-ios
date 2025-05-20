import Foundation

protocol CreditCardPaymentFormViewModelProtocol {
    var input: CreditCardPaymentFormViewModelInput { get }
    var output: CreditCardPaymentFormViewModelOutput { get }
}

protocol CreditCardPaymentFormViewModelInput {
    func viewDidLoad()
    func didCancelForm()
    func startPayment(for payment: CreditCardPayment)
    func set(loadingClosure: ParamClosure<Bool>)
    func set(countryClosure: ParamClosure<Country>)
    func getBrandImage(for brand: CardBrand?) -> String?
}

protocol CreditCardPaymentFormViewModelOutput {
    var numberError: String { get }
    var nameError: String { get }
    var expiryError: String { get }
    var cvvError: String { get }
    var shouldShouldAddressFields: Bool { get }
    var countryViewModel: CountryListViewModelProtocol { get }
}

enum CreditCardPaymentOption {
    case card
    case whiteLabelInstallment(payment: Source.Payment)
}
