import UIKit

struct AtomePaymentFormViewContext {
    enum Field: String, CaseIterable {
        case name
        case email
        case phoneNumber
        case country
        case city
        case postalCode
        case state
        case street1
        case street2
        case billingCountry
        case billingCity
        case billingPostalCode
        case billingState
        case billingStreet1
        case billingStreet2
    }
    
    private var fields: [Field: String] = [:]
    
    init(fields: [Field: String] = [:]) {
        self.fields = fields
    }
    
    subscript(field: Field) -> String {
        get {
            fields[field] ?? ""
        }
        set {
            fields[field] = newValue
        }
    }
}

extension AtomePaymentFormViewContext.Field {
    var isOptional: Bool {
        if isBilling {return true }
        
        switch self {
        case .name, .email, .street2: return true
        default: return false
        }
    }
    
    var isBilling: Bool {
        switch self {
        case .billingCountry,
                .billingCity,
                .billingPostalCode,
                .billingState,
                .billingStreet1,
                .billingStreet2:
            return true
        default:
            return false
        }
    }
    
    var title: String {
        "Atome.field.\(self.rawValue)".localized()
    }
    
    var validatorRegex: String? {
        switch self {
        case .phoneNumber: return "^(\\+\\d{2}|0)\\d{9}$"
        case .email: return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        default: return nil
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .phoneNumber: return .phonePad
        case .postalCode, .street1, .street2,
                .billingPostalCode, .billingStreet1, .billingStreet2: return .numbersAndPunctuation
        default: return .asciiCapable
        }
    }
    
    var capitalization: UITextAutocapitalizationType {
        switch self {
        case .name, .city, .state, .street1, .street2,
                .billingCity, .billingState, .billingStreet1, .billingStreet2: return .words
        case .country, .billingCountry: return .allCharacters
        default: return .none
        }
    }
    
    var contentType: UITextContentType {
        switch self {
        case .name: return .name
        case .phoneNumber: return .telephoneNumber
        case .email: return .emailAddress
        case .country, .billingCountry: return .countryName
        case .city, .billingCity: return .addressCity
        case .postalCode, .billingPostalCode: return .postalCode
        case .state, .billingState: return .addressState
        case .street1, .billingStreet1: return .streetAddressLine1
        case .street2, .billingStreet2: return .streetAddressLine2
        }
    }
    
    var error: String? {
        switch self {
        case .name, .street2, .billingStreet1, .billingStreet2, .billingCity,
                .billingState, .billingCountry, .billingPostalCode: return nil
        default: return "Atome.field.\(self.rawValue).error".localized()
        }
    }
}
