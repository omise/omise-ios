//
//  PaymentMethodNew.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/2/24.
//  Copyright © 2024 Omise. All rights reserved.
//

import Foundation

extension CapabilityNew {
    public struct PaymentMethod: Codable {
        let name: String

        private enum CodingKeys: String, CodingKey {
            case name
        }
    }
}

extension CapabilityNew.PaymentMethod {
    enum PaymentMethodType {
        case card
        case source(SourceType)
        case unsupported(paymentMethod: String)
    }

    var isCardType: Bool {
        name == "card"
    }
    
    var type: PaymentMethodType {
        if let sourceType = SourceType(rawValue: name) {
            return .source(sourceType)
        } else if isCardType {
            return .card
        } else {
            return .unsupported(paymentMethod: name)
        }
    }
}
