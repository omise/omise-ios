import Foundation

class AtomePaymentFormViewModel: AtomePaymentFormViewModelProtocol, CountryListViewModelProtocol {
    var billingAddressFields: [Field] {
        let billing: [Field] = [
            .billingStreet1,
            .billingStreet2,
            .billingCity,
            .billingState,
            .billingCountry,
            .billingPostalCode
        ]
        return billing
    }
    
    var fields: [Field] {
        var fieldList: [Field] = [
            .name,
            .email,
            .phoneNumber,
            .street1,
            .street2,
            .city,
            .state,
            .country,
            .postalCode
        ]
        fieldList.append(contentsOf: billingAddressFields)
        
        return fieldList
    }
    
    private weak var delegate: SelectSourcePaymentDelegate?
    private let amount: Int64
    
    // MARK: CountryListViewModelProtocol
    lazy var countries: [Country] = Country.sortedAll
    private var _filteredCountries: [Country] = []
    var filteredCountries: [Country] {
        return _filteredCountries.isEmpty ? countries : _filteredCountries
    }
    
    var selectedCountry: Country? {
        didSet {
            if let selectedCountry = selectedCountry {
                onSelectCountry(selectedCountry)
            }
        }
    }
    
    var onSelectCountry: (Country) -> Void = { _ in /* Non-optional default empty implementation */ }
    
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
        selectedCountry = filteredCountries[index]
    }
    
    var countryListViewModel: CountryListViewModelProtocol { return self }
    var shippingCountry: Country?
    var billingCountry: Country?
    
    var fieldForShippingAddressHeader: Field? { .street1 }
    var fieldForBillingAddressHeader: Field? { .billingStreet1 }
    var submitButtonTitle = "Atome.submitButton.title".localized()
    var headerText = "Atome.header.text".localized()
    var logoName = "Atome_Big"
    
    init(amount: Int64, currentCountry: Country?, delegate: SelectSourcePaymentDelegate?) {
        self.amount = amount
        self.delegate = delegate
        self.selectedCountry = currentCountry
    }
    
    func title(for field: Field) -> String? {
        var title = field.title.localized()
        if field.isOptional && !field.isBilling {
            title += " " + "Atome.field.optional".localized()
        }
        return title
    }
    
    func error(for field: Field, validate text: String?) -> String? {
        if field.isOptional && (text?.isEmpty ?? true) {
            return nil
        }
        
        if let validatorRegex = field.validatorRegex,
           let regex = try? NSRegularExpression(pattern: validatorRegex, options: []) {
            do {
                try regex.validate(text ?? "")
                return nil
            } catch {
                return field.error ?? error.localizedDescription
            }
        } else {
            if let text = text, text.isEmpty {
                return field.error
            }
        }
        
        return nil
    }
    
    func onSubmitButtonPressed(_ viewContext: ViewContext, onComplete: @escaping () -> Void) {
        guard let delegate = delegate else {
            onComplete()
            return
        }
        let shippingAddress = Source.Payment.Address(
            countryCode: viewContext[.country],
            city: viewContext[.city],
            state: viewContext[.state],
            street1: viewContext[.street1],
            street2: viewContext[.street2],
            postalCode: viewContext[.postalCode]
        )
        
        let billingAddress = Source.Payment.Address(
            countryCode: viewContext[.billingCountry],
            city: viewContext[.billingCity],
            state: viewContext[.billingState],
            street1: viewContext[.billingStreet1],
            street2: viewContext[.billingStreet2],
            postalCode: viewContext[.billingPostalCode]
        )
        
        let items: [Source.Payment.Item] = [
            Source.Payment.Item(
                sku: "3427842",
                category: "Shoes",
                name: "Prada shoes",
                quantity: 1,
                amount: amount,
                itemUri: "omise.co/product/shoes",
                imageUri: "omise.co/product/shoes/image",
                brand: "Gucci"
            )
        ]
        
        let paymentInformation = Source.Payment.Atome(
            phoneNumber: viewContext[.phoneNumber],
            shipping: shippingAddress,
            billing: billingAddress,
            items: items
        )
        
        delegate.didSelectSourcePayment(.atome(paymentInformation), completion: onComplete)
    }
}
