//
//  CountryListViewModelProtocol.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

protocol CountryListViewModelProtocol {
    var countries: [Country] { get }
    var selectedCountry: Country? { get set }
    var onSelectCountry: (Country) -> Void { get set }
}
