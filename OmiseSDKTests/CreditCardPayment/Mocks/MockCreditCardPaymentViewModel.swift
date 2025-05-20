import XCTest
@testable import OmiseSDK

class MockCreditCardPaymentViewModel:
    CreditCardPaymentFormViewModelProtocol,
    CreditCardPaymentFormViewModelInput,
    CreditCardPaymentFormViewModelOutput {
    
    private var _onSelectCountry: (Country) -> Void = { _ in }
    
    // Expose them so tests can drive
    var loadingClosure: ParamClosure<Bool> = nil
    var countryClosure: ParamClosure<Country> = nil
    
    // control flags
    var shouldShowAddressFields = false
    var viewDidLoadCalled = false
    var didCancelCalled = false
    var startPaymentCalledWith: CreditCardPayment?
    
    // MARK: Protocol plumbing
    var input: CreditCardPaymentFormViewModelInput { return self }
    var output: CreditCardPaymentFormViewModelOutput { return self }
    
    // MARK: — Input
    func viewDidLoad() {
        viewDidLoadCalled = true
        // simulate sending back an initial country if you like:
        // countryClosure?(Country(code: "US")!)
    }
    
    func set(loadingClosure: ParamClosure<Bool>) {
        self.loadingClosure = loadingClosure
    }
    
    func set(countryClosure: ParamClosure<Country>) {
        self.countryClosure = countryClosure
    }
    
    func didCancelForm() {
        didCancelCalled = true
    }
    
    func startPayment(for payment: CreditCardPayment) {
        startPaymentCalledWith = payment
    }
    
    func getBrandImage(for brand: CardBrand?) -> String? {
        return brand?.rawValue
    }
    
    // MARK: — Output
    var numberError: String { "numErr" }
    var nameError: String { "nameErr" }
    var expiryError: String { "expErr" }
    var cvvError: String { "cvvErr" }
    
    var shouldShouldAddressFields: Bool {
        return shouldShowAddressFields
    }
    
    var countryViewModel: CountryListViewModelProtocol {
        return self
    }
}

extension MockCreditCardPaymentViewModel: CountryListViewModelProtocol {
    var onSelectCountry: (Country) -> Void {
        get {
            _onSelectCountry
        }
        set(newValue) {
            _onSelectCountry = newValue
        }
    }
    
    var countries: [Country] {
        Country.all
    }
    
    var selectedCountry: Country? {
        get {
            Country(code: "TH")
        }
        set(newValue) { // swiftlint:disable:this unused_setter_value
            
        }
    }
}
