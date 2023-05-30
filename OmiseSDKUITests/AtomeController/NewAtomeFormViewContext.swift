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
        case phoneNumber
        case email
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
    
    mutating func setValue(_ value: String?, for field: Field) {
        fields[field] = value
    }
    
    func value(for field: Field) -> String? {
        fields[field]
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
        NSLocalizedString("Atome.field.\(self.rawValue)",
                          tableName: "Localizable",
                          bundle: .omiseSDK,
                          value: self.rawValue.capitalized,
                          comment: "Atome field name"
        )
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
}
