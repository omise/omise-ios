import Foundation

public enum Required3DSData {
    case none
    case phoneNumber
    case email
    case all
    
    var shouldRenderEmailField: Bool {
        self == .all || self == .email
    }
    
    var shouldRenderPhoneField: Bool {
        self == .all || self == .phoneNumber
    }
}

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
    var emailError: String { get }
    var phoneError: String { get }
    var shouldAddressFields: Bool { get }
    var countryViewModel: CountryListViewModelProtocol { get }
    var shouldshowEmailField: Bool { get }
    var shouldShowPhoneField: Bool { get }
}

enum CreditCardPaymentOption {
    case card
    case whiteLabelInstallment(payment: Source.Payment)
}
