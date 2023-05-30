//
//  Array+Helpers.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 30/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

extension Array {
    func at(_ index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
