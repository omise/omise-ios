import Foundation

class CreditCardPaymentFormViewModel: CreditCardPaymentFormViewModelProtocol, CountryListViewModelProtocol {
    var input: CreditCardPaymentFormViewModelInput { self }
    var output: CreditCardPaymentFormViewModelOutput { self }
    
    var selectedCountry: Country? {
        didSet {
            if let selectedCountry = selectedCountry {
                currentCountry = selectedCountry
                countryClosure?(selectedCountry)
            }
        }
    }
    lazy var countries: [Country] = Country.sortedAll
    
    var onSelectCountry: (Country) -> Void = { _ in /* Non-optional default empty implementation */ }
    
    weak var delegate: CreditCardPaymentDelegate?
    
    private var loadingClosure: ParamClosure<Bool> = nil
    private var countryClosure: ParamClosure<Country> = nil
    
    private var currentCountry: Country?
    private let option: CreditCardPaymentOption
    
    init(
        country: Country?,
        paymentOption: CreditCardPaymentOption,
        delegate: CreditCardPaymentDelegate?
    ) {
        self.delegate = delegate
        self.currentCountry = country
        self.option = paymentOption
    }
}

// MARK: - Input
extension CreditCardPaymentFormViewModel: CreditCardPaymentFormViewModelInput {
    func viewDidLoad() {
        if let country = self.currentCountry {
            countryClosure?(country)
        }
    }
    
    func didCancelForm() {
        delegate?.didCancelCardPayment()
    }
    
    func startPayment(for payment: CreditCardPayment) {
        let card = CreateTokenPayload.Card(
            name: payment.name,
            number: payment.pan,
            expirationMonth: payment.expiryMonth,
            expirationYear: payment.expiryYear,
            securityCode: payment.cvv,
            phoneNumber: nil,
            countryCode: currentCountry?.code,
            city: payment.city,
            state: payment.state,
            street1: payment.address,
            street2: nil,
            postalCode: payment.zipcode
        )
        
        loadingClosure?(true)
        delegate?.didSelectCardPayment(paymentType: option,
                                       card: card) { [weak self] in
            guard let self = self else { return }
            self.loadingClosure?(false)
        }
    }
    
    func set(loadingClosure: ParamClosure<Bool>) {
        self.loadingClosure = loadingClosure
    }
    
    func set(countryClosure: ParamClosure<Country>) {
        self.countryClosure = countryClosure
    }
    
    func getBrandImage(for brand: CardBrand?) -> String? {
        switch brand {
        case .visa:
            return "Visa"
        case .masterCard:
            return "Mastercard"
        case .jcb:
            return "JCB"
        case .amex:
            return "AMEX"
        case .diners:
            return "Diners"
        case .unionPay:
            return "UnionPay"
        case .discover:
            return "Discover"
        default:
            return nil
        }
    }
}

// MARK: - Output
extension CreditCardPaymentFormViewModel: CreditCardPaymentFormViewModelOutput {
    var countryViewModel: CountryListViewModelProtocol { return self }
    
    var shouldAddressFields: Bool {
        self.currentCountry?.isAVS ?? false
    }
    
    var numberError: String {
        NSLocalizedString(
            "credit-card-form.card-number-field.invalid-data.error.text",
            tableName: "Error",
            bundle: .omiseSDK,
            value: "Credit card number is invalid",
            comment: "An error text displayed when the credit card number is invalid"
        )
    }
    
    var expiryError: String {
        NSLocalizedString(
            "credit-card-form.expiry-date-field.invalid-data.error.text",
            tableName: "Error",
            bundle: .omiseSDK,
            value: "Card expiry date is invalid",
            comment: "An error text displayed when the expiry date is invalid"
        )
    }
    
    var cvvError: String {
        NSLocalizedString(
            "credit-card-form.security-code-field.invalid-data.error.text",
            tableName: "Error",
            bundle: .omiseSDK,
            value: "CVV code is invalid",
            comment: "An error text displayed when the security code is invalid"
        )
    }
    
    var nameError: String {
        NSLocalizedString(
            "credit-card-form.card-holder-name-field.invalid-data.error.text",
            tableName: "Error",
            bundle: .omiseSDK,
            value: "Card holder name is invalid",
            comment: "An error text displayed when the card holder name is invalid"
        )
    }
}

struct CreditCardPayment {
    let pan: String
    let name: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
    let country: String
    let address: String?
    let state: String?
    let city: String?
    let zipcode: String?
}
