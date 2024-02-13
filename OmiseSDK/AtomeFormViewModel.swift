//
//  AtomeFormViewModel.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 31/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

class AtomeFormViewModel: AtomeFormViewModelProtocol, CountryListViewModelProtocol {
    var fields: [Field] = [
        .name,
        .email,
        .phoneNumber,
        .street1,
        .street2,
        .city,
        .state,
        .country,
        .postalCode
    ]

    // MARK: CountryListViewModelProtocol
    lazy var countries: [Country] = Country.sortedAll

    lazy var selectedCountry: Country? = OmiseSDK.shared.currentCountry {
        didSet {
            if let selectedCountry = selectedCountry {
                onSelectCountry(selectedCountry)
            }
        }
    }
    var onSelectCountry: (Country) -> Void = { _ in }

    var countryListViewModel: CountryListViewModelProtocol { return self }
    
    var fieldForShippingAddressHeader: Field? { .street1 }
    var submitButtonTitle = "Atome.submitButton.title".localized()
    var headerText = "Atome.header.text".localized()
    var logoName = "Atome_Big"

    private let flowSession: PaymentCreatorFlowSession?

    init(flowSession: PaymentCreatorFlowSession?) {
        self.flowSession = flowSession
    }

    func title(for field: Field) -> String? {
        var title = field.title.localized()
        if field.isOptional {
            title += " " + "Atome.field.optional".localized()
        }
        return title
    }

    func error(for field: Field, validate text: String?) -> String? {
        if field.isOptional, text?.isEmpty ?? true { return nil }

        if let validatorRegex = field.validatorRegex,
            let regex = try? NSRegularExpression(pattern: validatorRegex, options: []) {
            do {
                try regex.validate(text ?? "")
                return nil
            } catch {
                return field.error ?? error.localizedDescription
            }
        } else {
            if let text = text, text.isEmpty {
                return field.error
            }
        }

        return nil
    }

    func onSubmitButtonPressed(_ viewContext: ViewContext, onComplete: @escaping () -> Void) {
        guard let flowSession = flowSession else {
            onComplete()
            return
        }
        let shippingAddress = Source.Payment.Address(
            country: viewContext[.country],
            city: viewContext[.city],
            postalCode: viewContext[.postalCode],
            state: viewContext[.state],
            street1: viewContext[.street1],
            street2: viewContext[.street2]
        )

        let items: [Source.Payment.Item] = [
            .init(
                sku: "3427842",
                category: "Shoes",
                name: "Prada shoes",
                quantity: 1,
                amount: flowSession.paymentAmount ?? 0,
                itemUri: "omise.co/product/shoes",
                imageUri: "omise.co/product/shoes/image",
                brand: "Gucci"
            )
        ]

        let atomePayment = Source.Payment.atome(
            .init(
                phoneNumber: viewContext[.phoneNumber],
                shipping: shippingAddress,
                billing: nil,
                items: items
            )
        )

        flowSession.requestCreateSource(atomePayment) { _ in
            onComplete()
        }
    }
}
