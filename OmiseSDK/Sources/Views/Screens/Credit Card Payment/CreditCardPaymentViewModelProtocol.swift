//
//  CreditCardPaymentViewModelProtocol.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 19/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

protocol CreditCardPaymentViewModelProtocol {
    typealias ViewContext = CreditCardPaymentViewContext
    typealias AddressField = ViewContext.Field
    var addressFields: [AddressField] { get }
    var fieldForShippingAddressHeader: AddressField? { get }
    var countryListViewModel: CountryListViewModelProtocol { get }
    var isAddressFieldsVisible: Bool { get }
    
    func onSubmitButtonPressed(_ viewContext: ViewContext, completion: @escaping () -> Void )
    func error(for: AddressField, validate: String?) -> String?
    func title(for: AddressField) -> String?
    func placeholder(for: AddressField) -> String?
    func keyboardType(for: AddressField) -> UIKeyboardType
    func capitalization(for: AddressField) -> UITextAutocapitalizationType
    func contentType(for: AddressField) -> UITextContentType
}

extension CreditCardPaymentViewModelProtocol {
    func isSubmitButtonEnabled(_ viewContext: ViewContext) -> Bool {
        addressFields.allSatisfy {
            error(for: $0, validate: viewContext[$0]) == nil
        }
    }

    func validate(_ viewContext: ViewContext, value: String?) -> [AddressField: String] {
        var errors: [AddressField: String] = [:]
        for field in addressFields {
            if let error = error(for: field, validate: viewContext[field]) {
                errors[field] = error
            }
        }
        return errors
    }

    func placeholder(for field: AddressField) -> String? {
        return field.title
    }

    func keyboardType(for field: AddressField) -> UIKeyboardType {
        return field.keyboardType
    }
    func capitalization(for field: AddressField) -> UITextAutocapitalizationType {
        return field.capitalization
    }
    func contentType(for field: AddressField) -> UITextContentType {
        return field.contentType
    }
}
