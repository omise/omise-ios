//
//  NewAtomeFormViewModelProtocol.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

protocol NewAtomeFormViewModelProtocol {
    typealias ViewContext = NewAtomeFormViewContext
    typealias Field = ViewContext.Field
    var fields: [Field] { get }
    var submitButtonTitle: String { get }
    var headerText: String { get }
    var logoName: String { get }
    var fieldForShippingAddressHeader: Field? { get }

    func onSubmitButtonPressed(_ viewContext: ViewContext, onComplete: @escaping  () -> Void)
    func error(for: Field, validate: String?) -> String?
    func title(for: Field) -> String?
    func placeholder(for: Field) -> String?
    func keyboardType(for: Field) -> UIKeyboardType
    func capitalization(for: Field) -> UITextAutocapitalizationType
    func contentType(for: Field) -> UITextContentType
}

extension NewAtomeFormViewModelProtocol {
    func isSubmitButtonEnabled(_ viewContext: ViewContext) -> Bool {
        Field.allCases.allSatisfy {
            error(for: $0, validate: viewContext[$0]) == nil
        }
    }

    func validate(_ viewContext: ViewContext, value: String?) -> [Field: String] {
        var errors: [Field: String] = [:]
        for field in Field.allCases {
            if let error = error(for: field, validate: viewContext[field]) {
                errors[field] = error
            }
        }
        return errors
    }

    func placeholder(for field: Field) -> String? {
        return field.title
    }

    func keyboardType(for field: Field) -> UIKeyboardType {
        return field.keyboardType
    }
    func capitalization(for field: Field) -> UITextAutocapitalizationType {
        return field.capitalization
    }
    func contentType(for field: Field) -> UITextContentType {
        return field.contentType
    }
}
