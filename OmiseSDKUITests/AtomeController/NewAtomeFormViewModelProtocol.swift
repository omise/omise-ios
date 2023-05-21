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
    func validate(_ field: Field) -> String?
    func process(_ viewContext: ViewContext, onComplete:()->())
}

extension NewAtomeFormViewModelProtocol {
    var isNextButtonEnabled: Bool {
        Field.allCases.compactMap(validate).isEmpty
    }
}
