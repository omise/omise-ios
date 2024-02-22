//
//  CreditCardPaymentViewModel.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 19/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import os.log

class CreditCardPaymentViewModel: CreditCardPaymentViewModelProtocol, CountryListViewModelProtocol {
    var addressFields: [AddressField] = [.address, .city, .state, .postalCode]
    
    var fieldForShippingAddressHeader: AddressField?

    var isAddressFieldsVisible: Bool {
        selectedCountry?.isAVS ?? false
    }

    func title(for field: AddressField) -> String? {
        field.title
    }
    
    var countryListViewModel: CountryListViewModelProtocol { return self }

    private weak var delegate: CreditCardPaymentDelegate?

    init(delegate: CreditCardPaymentDelegate?) {
        self.delegate = delegate
    }

    // MARK: CountryListViewModelProtocol
    lazy var countries: [Country] = Country.sortedAll
    
    lazy var selectedCountry: Country? = OmiseSDK.shared.country {
        didSet {
            if let selectedCountry = selectedCountry {
                onSelectCountry(selectedCountry)
            }
        }
    }
    var onSelectCountry: (Country) -> Void = { _ in }

    func error(for field: AddressField, validate text: String?) -> String? {
        guard isAddressFieldsVisible else { return nil }
        let result = (text?.isEmpty ?? true) ? field.error : nil
        return result
    }

    func viewDidTapClose() {
        delegate?.didCancelCardPayment()
    }

    func onSubmitButtonPressed(_ viewContext: ViewContext) {

        let card = CreateTokenPayload.Card(
            name: viewContext.name,
            number: viewContext.number,
            expirationMonth: viewContext.expirationMonth,
            expirationYear: viewContext.expirationYear,
            securityCode: viewContext.securityCode,
            phoneNumber: nil,
            countryCode: viewContext.countryCode,
            city: viewContext[.city],
            state: viewContext[.state],
            street1: viewContext[.address],
            street2: nil,
            postalCode: viewContext[.postalCode]
        )

        delegate?.didSelectCardPayment(card)

        /*
        viewModel.onSubmitButtonPressed(makeViewContext(), publicKey: publicKey) { [weak self] result in
            guard let self = self else { return }
            self.stopActivityIndicator()
            switch result {
            case .success(let token):
                os_log("Credit Card Form's Request succeed %{private}@, trying to notify the delegate",
                       log: uiLogObject,
                       type: .default,
                       token.id)
                self.delegate?.creditCardFormViewController(self, didSucceedWithToken: token)
            case .failure(let error):
                self.handleError(error)
            }
        }
         */

//        guard let publicKey = publicKey else {
//            os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, publicKey ?? "")
//            assertionFailure("Missing public key information. Please set the public key before request token.")
//            return
//        }
//
//        os_log("Requesting to create token", log: uiLogObject, type: .info)
//
//        let payload = CreateTokenPayload.Card(
//            name: viewContext.name,
//            number: viewContext.number,
//            expirationMonth: viewContext.expirationMonth,
//            expirationYear: viewContext.expirationYear,
//            securityCode: viewContext.securityCode,
//            phoneNumber: nil,
//            countryCode: viewContext.countryCode,
//            city: viewContext[.city],
//            state: viewContext[.state],
//            street1: viewContext[.address],
//            street2: nil,
//            postalCode: viewContext[.postalCode]
//        )
//
//        let client = OmiseSDK(publicKey: publicKey).client
//        client.createToken(payload: payload) { result in
//            onComplete(result)
//        }
    }

}
