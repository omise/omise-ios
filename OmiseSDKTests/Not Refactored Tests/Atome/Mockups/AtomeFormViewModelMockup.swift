import Foundation
import UIKit
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

class AtomePaymentFormViewModelMockup: AtomePaymentFormViewModelProtocol {
    var submitButtonTitle: String = "Next"
    var headerText: String = "Header"
    var logoName: String = "AtomeLogo"
    private(set) var submitCalledCount = 0
    private(set) var lastViewContext: AtomePaymentFormViewContext?
    var isSubmitButtonEnabledReturn = false
    
    var titles: [Field: String] = [:]
    var errors: [Field: String] = [:]
    
    var shippingCountry: Country?
    var billingCountry: Country?
    
    private lazy var _countryVM = CountryListViewModelMockup()
    var countryListViewModel: CountryListViewModelProtocol { return _countryVM }
    
    var countries: [Country] { return _countryVM.countries }
    var selectedCountry: Country? {
        get { _countryVM.selectedCountry }
        set { _countryVM.selectedCountry = newValue }
    }
    
    var fieldForShippingAddressHeader: Field? { .street1 }
    var fieldForBillingAddressHeader: Field? { .billingStreet1 }
    
    var fields: [Field] = Field.allCases
    
    var billingAddressFields: [Field] = [
        .billingStreet1,
        .billingStreet2,
        .billingCity,
        .billingState,
        .billingCountry,
        .billingPostalCode
    ]
    
    init(
        submitButtonTitle: String? = nil,
        customTitles: [Field: String]? = nil,
        customErrors: [Field: String]? = nil
    ) {
        if let t = submitButtonTitle { self.submitButtonTitle = t }
        if let c = customTitles { self.titles = c }
        if let e = customErrors { self.errors = e }
    }
    
    func onSubmitButtonPressed(
        _ viewContext: AtomePaymentFormViewContext,
        onComplete: @escaping () -> Void
    ) {
        submitCalledCount += 1
        lastViewContext = viewContext
        onComplete()
    }
    
    func error(for field: Field, validate text: String?) -> String? {
        if !isSubmitButtonEnabledReturn {
            return "SomeError"
        }
        return errors[field]
    }
    
    func title(for field: Field) -> String? {
        if let override = titles[field] {
            return override
        }
        let base = field.title.localized()
        if field.isOptional && !field.isBilling {
            return "\(base) " + "Atome.field.optional".localized()
        }
        return base
    }
    
    func placeholder(for field: Field) -> String? {
        "Placeholder:\(field.rawValue)"
    }
    
    func keyboardType(for field: Field) -> UIKeyboardType {
        field.keyboardType
    }
    
    func capitalization(for field: Field) -> UITextAutocapitalizationType {
        field.capitalization
    }
    
    func contentType(for field: Field) -> UITextContentType {
        field.contentType
    }
}

extension AtomePaymentFormViewModelMockup {
    @discardableResult
    func withAllTitles() -> Self {
        // Populate `titles[...] = field.rawValue` for every field
        self.titles = Field.allCases.reduce(into: [Field: String]()) { dict, key in
            dict[key] = key.rawValue
        }
        return self
    }
    
    @discardableResult
    func withAllFields() -> Self {
        // By default, we already set `fields = Field.allCases` in the init above,
        // so you can omit this if you want every single field. But if you want
        // to preserve a subset of them, you could do:
        self.fields = Field.allCases
        return self
    }
}
