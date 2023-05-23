//
//  NewAtomeFormViewModelProtocol.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

protocol NewAtomeFormViewModelProtocol {
    typealias ViewContext = NewAtomeFormViewContext
    typealias Field = ViewContext.Field
    var titleForNextButton: String { get }
    func onNextButtonPressed(_ viewContext: ViewContext, onComplete: () -> Void)
    func error(for: Field, value: String?) -> String?
    func title(for: Field) -> String?
}

extension NewAtomeFormViewModelProtocol {
    func isNextEnabled(_ viewContext: ViewContext) -> Bool {
        Field.allCases.allSatisfy {
            error(for: $0, value: viewContext.value(for: $0)) == nil
        }
    }

    func validate(_ viewContext: ViewContext, value: String?) -> [Field: String] {
        var errors: [Field: String] = [:]
        for field in Field.allCases {
            if let error = error(for: field, value: viewContext.value(for: field)) {
                errors[field] = error
            }
        }
        return errors
    }
}
