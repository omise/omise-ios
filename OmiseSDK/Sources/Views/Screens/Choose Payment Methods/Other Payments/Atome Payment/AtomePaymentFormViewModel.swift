import Foundation

class AtomePaymentFormViewModel: AtomePaymentFormViewModelProtocol, CountryListViewModelProtocol {
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

    private weak var delegate: SelectSourcePaymentDelegate?
    private let amount: Int64

    // MARK: CountryListViewModelProtocol
    lazy var countries: [Country] = Country.sortedAll

    var selectedCountry: Country? {
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

    init(amount: Int64, currentCountry: Country?, delegate: SelectSourcePaymentDelegate?) {
        self.amount = amount
        self.delegate = delegate
        self.selectedCountry = currentCountry
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
        guard let delegate = delegate else {
            onComplete()
            return
        }
        let shippingAddress = Source.Payment.Address(
            countryCode: viewContext[.country],
            city: viewContext[.city],
            state: viewContext[.state],
            street1: viewContext[.street1],
            street2: viewContext[.street2],
            postalCode: viewContext[.postalCode]
        )

        let items: [Source.Payment.Item] = [
            Source.Payment.Item(
                sku: "3427842",
                category: "Shoes",
                name: "Prada shoes",
                quantity: 1,
                amount: amount,
                itemUri: "omise.co/product/shoes",
                imageUri: "omise.co/product/shoes/image",
                brand: "Gucci"
            )
        ]

        let paymentInformation = Source.Payment.Atome(
            phoneNumber: viewContext[.phoneNumber],
            shipping: shippingAddress,
            billing: nil,
            items: items
        )

        delegate.didSelectSourcePayment(.atome(paymentInformation), completion: onComplete)
    }
}
