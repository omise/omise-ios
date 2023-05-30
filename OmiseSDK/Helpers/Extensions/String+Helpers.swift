//
//  String+Helpers.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 30/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

extension String {
    func localized(_ defaultValue: String? = nil) -> String {
        NSLocalizedString(self,
                          tableName: "Localizable",
                          bundle: .omiseSDK,
                          value: defaultValue ?? self,
                          comment: "")
    }
}
