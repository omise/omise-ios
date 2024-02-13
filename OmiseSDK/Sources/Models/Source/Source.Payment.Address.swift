import Foundation

extension Source.Payment {
    /// `Shipping` or `Billing` address
    /// https://docs.opn.ooo/sources-api
    public struct Address: Codable, Equatable {
        /// Address country as two-letter ISO 3166 code
        let country: String
        /// Address city
        let city: String
        /// Address postal code
        let postalCode: String
        /// Address state
        let state: String
        /// Address street #1
        let street1: String
        /// Address street #2
        let street2: String?

        /// Creates a new Shipping or Billing address source with the given details
        ///
        /// - Parameters:
        ///   - country: Address country as two-letter ISO 3166 code
        ///   - city: Address city
        ///   - postalCode: Address postal code
        ///   - state: Address state
        ///   - street1: Address street #1
        ///   - street2: Address street #2
        init(country: String, city: String, postalCode: String, state: String, street1: String, street2: String?) {
            self.country = country
            self.city = city
            self.postalCode = postalCode
            self.state = state
            self.street1 = street1
            self.street2 = street2
        }
    }
}

extension Source.Payment.Address {
    private enum CodingKeys: String, CodingKey {
        case country
        case city
        case postalCode = "postal_code"
        case state
        case street1
        case street2
    }
}
