//
//  NewAtomeFormViewContext.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

struct NewAtomeFormViewContext {
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

extension NewAtomeFormViewContext.Field {
    var isOptional: Bool {
        switch self {
        case .name, .email, .street2: return true
        default: return false
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
        case .postalCode, .street1, .street2: return .numbersAndPunctuation
        default: return .asciiCapable
        }
    }

    var capitalization: UITextAutocapitalizationType {
        switch self {
        case .name, .city, .state, .street1, .street2: return .words
        case .country: return .allCharacters
        default: return .none
        }
    }

    var contentType: UITextContentType {
        switch self {
        case .name: return .name
        case .phoneNumber: return .telephoneNumber
        case .email: return .emailAddress
        case .country: return .countryName
        case .city: return .addressCity
        case .postalCode: return .postalCode
        case .state: return .addressState
        case .street1: return .streetAddressLine1
        case .street2: return .streetAddressLine2
        }
    }

    var error: String? {
        switch self {
        case .name, .street2: return nil
        default: return "Atome.field.\(self.rawValue).error".localized()
        }
    }
}
