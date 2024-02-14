import Foundation

extension Token {
    /// Represents Token.Card JSON object for communication with Omise API
    public struct Card {
        /// Card's ID.
        public let id: String
        /// Boolean flag indicating wether this card is a live card or a test card.
        public let isLiveMode: Bool
        /// Card brand. (e.g. Visa, Mastercard, ...)
        public let brand: String?
        /// Card bank name.
        public let bank: String?
        /// Card holder's full name.
        public let name: String?
        /// Last 4 digits of the card number.
        public let lastDigits: String?
        /// Card expiration month (1-12)
        public let expirationMonth: Int?
        /// Card expiration year (Gregrorian)
        public let expirationYear: Int?
        /// Unique card-based fingerprint. Allows detection of identical cards without
        /// exposing card numbers directly.
        public let fingerprint: String?
        /// Credit card financing type. (debit or credit)
        public let financing: String?
        /// Boolean indicates that whether that the card is passed the security code check
        public let securityCodeCheck: Bool
        /// ISO3166 Country code based on the card number.
        /// - note: This is informational only and may not always be 100% accurate.
        public let countryCode: String?
        /// Issuing city.
        /// - note: This is informational only and may not always be 100% accurate.
        public let city: String?
        /// Postal code.
        public let postalCode: String?
    }
}

extension Token.Card: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case isLiveMode = "livemode"
        case brand
        case bank
        case name
        case lastDigits = "last_digits"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case fingerprint
        case financing
        case securityCodeCheck = "security_code_check"
        case countryCode = "country"
        case city
        case postalCode = "postal_code"
    }
}
