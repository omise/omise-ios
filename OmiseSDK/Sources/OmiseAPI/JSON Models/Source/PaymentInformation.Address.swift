import Foundation

// TODO: Address
extension PaymentInformation {
    /// `Shipping` or `Billing` address
    /// https://docs.opn.ooo/sources-api
    public struct Address: Equatable {
        /// Address country as two-letter ISO 3166 code
        public let countryCode: String
        /// Address city
        public let city: String
        /// Address state
        public let state: String
        /// Address street #1
        public let street1: String
        /// Address street #2
        public let street2: String?
        /// Address postal code
        public let postalCode: String

        /// Creates a new Shipping or Billing address source with the given details
        ///
        /// - Parameters:
        ///   - country: Address country as two-letter ISO 3166 code
        ///   - city: Address city
        ///   - postalCode: Address postal code
        ///   - state: Address state
        ///   - street1: Address street #1
        ///   - street2: Address street #2
        public init(countryCode: String, city: String, state: String, street1: String, street2: String?, postalCode: String) {
            self.countryCode = countryCode
            self.city = city
            self.postalCode = postalCode
            self.state = state
            self.street1 = street1
            self.street2 = street2
        }
    }
}

extension PaymentInformation.Address: Codable {
    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
        case city
        case postalCode = "postal_code"
        case state
        case street1
        case street2
    }
}
