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

    init(currentCountry: Country?, delegate: CreditCardPaymentDelegate?) {
        self.delegate = delegate
        self.selectedCountry = currentCountry
    }

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

    func error(for field: AddressField, validate text: String?) -> String? {
        guard isAddressFieldsVisible else { return nil }
        let result = (text?.isEmpty ?? true) ? field.error : nil
        return result
    }

    func viewDidTapClose() {
        delegate?.didCancelCardPayment()
    }

    func onSubmitButtonPressed(_ viewContext: ViewContext, completion: @escaping () -> Void) {

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

        delegate?.didSelectCardPayment(card, completion: completion)
    }
}
