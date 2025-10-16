import XCTest
@testable import OmiseSDK

class MockCreditCardPaymentViewModel:
    CreditCardPaymentFormViewModelProtocol,
    CreditCardPaymentFormViewModelInput,
    CreditCardPaymentFormViewModelOutput {
    
    private var _onSelectCountry: (Country) -> Void = { _ in }
    private var _filteredCountries: [Country] = []
    
    var loadingClosure: ParamClosure<Bool> = nil
    var countryClosure: ParamClosure<Country> = nil
    
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
        countryClosure?(.init(name: "United States of America", code: "US"))
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
    var emailError: String { "emailErr "}
    var phoneError: String { "phoneErr "}
    
    var shouldAddressFields: Bool {
        return shouldShowAddressFields
    }
    
    var shouldshowEmailField: Bool {
        true
    }
    
    var shouldShowPhoneField: Bool {
        true
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
    
    var filteredCountries: [Country] {
        return _filteredCountries.isEmpty ? countries : _filteredCountries
    }
    
    var selectedCountry: Country? {
        get {
            Country(code: "TH")
        }
        set(newValue) { // swiftlint:disable:this unused_setter_value
            
        }
    }
    
    func filterCountries(with searchText: String) {
        if searchText.isEmpty {
            _filteredCountries = []
        } else {
            _filteredCountries = countries.filter { country in
                let searchLower = searchText.lowercased()
                return country.name.lowercased().contains(searchLower) ||
                country.code.lowercased().contains(searchLower)
            }
        }
    }
    
    func updateSelectedCountry(at index: Int) {
        guard index >= 0 && index < filteredCountries.count else { return }
    }
}
