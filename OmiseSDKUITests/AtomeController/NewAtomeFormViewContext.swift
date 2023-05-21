//
//  NewAtomeFormViewContext.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

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

    var fields: [Field: String]
}
