//
//  CountryListViewModelProtocol.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

struct CountryInfo: Codable, Equatable {
    let name: String
    let code: String
}

protocol CountryListViewModelProtocol {
    var countries: [CountryInfo] { get }
    var selected: CountryInfo? { get set }
    var onSelect: (CountryInfo) -> Void { get set }
}
