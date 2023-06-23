//
//  CreditCardFormViewModel.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 19/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import os.log

class CreditCardFormViewModel: CreditCardFormViewModelProtocol, CountryListViewModelProtocol {
    var addressFields: [AddressField] = [.address, .city, .state, .postalCode]
    
    var fieldForShippingAddressHeader: AddressField?

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

    func onSubmitButtonPressed(_ viewContext: ViewContext, publicKey: String?, onComplete: @escaping (RequestResult<Token>) -> Void) {
        
        guard let publicKey = publicKey else {
            os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, publicKey ?? "")
            assertionFailure("Missing public key information. Please set the public key before request token.")
            return
        }

        os_log("Requesting to create token", log: uiLogObject, type: .info)

        let request = Request<Token>(
            name: viewContext.name,
            pan: viewContext.pan,
            expirationMonth: viewContext.expirationMonth,
            expirationYear: viewContext.expirationYear,
            securityCode: viewContext.securityCode,
            countryCode: viewContext.countryCode,
            city: viewContext[.city],
            state: viewContext[.state],
            street1: viewContext[.address],
            postalCode: viewContext[.postalCode]
        )

        let client = Client(publicKey: publicKey)
        client.send(request) { (result) in
            onComplete(result)
        }
    }

}
