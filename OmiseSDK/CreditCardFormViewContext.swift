//
//  CreditCardFormViewContext.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 19/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

struct CreditCardFormViewContext {
    enum Field: String, CaseIterable {
        case country
        case address
        case city
        case state
        case postalCode
    }

    private var fields: [Field: String] = [:]
    var countryCode: String?

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

extension CreditCardFormViewContext.Field {
    var isOptional: Bool {
        return false
    }

    var title: String {
        var title = "CreditCard.field.\(self.rawValue)".localized()
        if isOptional {
            title += " " + "CreditCard.field.optional".localized()
        }
        return title
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .postalCode, .address: return .numbersAndPunctuation
        default: return .asciiCapable
        }
    }

    var capitalization: UITextAutocapitalizationType {
        switch self {
        case .city, .state, .address: return .words
        default: return .none
        }
    }

    var contentType: UITextContentType {
        switch self {
        case .country: return .countryName
        case .city: return .addressCity
        case .postalCode: return .postalCode
        case .state: return .addressState
        case .address: return .streetAddressLine1
        }
    }

    var error: String? {
        switch self {
        default: return "CreditCard.field.\(self.rawValue).error".localized()
        }
    }
}
