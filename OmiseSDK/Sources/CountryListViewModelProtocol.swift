//
//  CountryListViewModelProtocol.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

protocol CountryListViewModelProtocol {
    var countries: [CountryInfo] { get }
    var selectedCountry: CountryInfo? { get set }
    var onSelectCountry: (CountryInfo) -> Void { get set }
}
