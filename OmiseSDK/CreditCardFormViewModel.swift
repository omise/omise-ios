//
//  CreditCardFormViewModel.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 19/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

class CreditCardFormViewModel: CreditCardFormViewModelProtocol, CountryListViewModelProtocol {
    var addressFields: [AddressField] = [.address, .city, .state, .postalCode]
    
    var fieldForShippingAddressHeader: AddressField?
    
    func onSubmitButtonPressed(_ viewContext: ViewContext, onComplete: @escaping () -> Void) {

    }

    var isAddressFieldsVisible: Bool {
        selectedCountry?.isAVS ?? false
    }

    func title(for field: AddressField) -> String? {
        field.title
    }
    
    var countryListViewModel: CountryListViewModelProtocol { return self }

    // MARK: CountryListViewModelProtocol
    lazy var countries: [CountryInfo] = CountryInfo.all.sorted { $0.name < $1.name }
    lazy var selectedCountry: CountryInfo? = CountryInfo.current {
        didSet {
            if let selectedCountry = selectedCountry {
                onSelectCountry(selectedCountry)
            }
        }
    }
    var onSelectCountry: (CountryInfo) -> Void = { _ in }

    func error(for field: AddressField, validate text: String?) -> String? {
        guard isAddressFieldsVisible else { return nil }
        let result = (text?.isEmpty ?? true) ? field.error : nil
        return result
    }
}
