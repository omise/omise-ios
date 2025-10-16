import Foundation

/// Card Information to create a token container
/// Used as payload in createToken API
public struct CreateTokenPayload: Codable, Equatable {
    public let card: Card

    public init(card: Card) {
        self.card = card
    }
    
    /// Card Information to create a token
    /// A token represents a credit or debit card
    /// https://docs.omise.co/tokens-api
    public struct Card: Equatable {
        /// Card holder's full name
        public let name: String
        /// Card number
        public let number: String
        /// Card expiration month (1-12)
        public let expirationMonth: Int
        /// Card expiration year (Gregorian)
        public let expirationYear: Int
        /// Security code (CVV, CVC, etc) printed on the back of the card
        public let securityCode: String
        /// Phone Numeber
        public let phoneNumber: String?
        /// Email
        public let email: String?
        /// Address country as two-letter ISO 3166 code
        public let countryCode: String?
        /// Address city
        public let city: String?
        /// Address state
        public let state: String?
        /// Address street #1
        public let street1: String?
        /// Address street #2
        public let street2: String?
        /// Address postal code
        public let postalCode: String?

        public init(
            name: String,
            number: String,
            expirationMonth: Int,
            expirationYear: Int,
            securityCode: String,
            phoneNumber: String? = nil,
            email: String? = nil,
            countryCode: String? = nil,
            city: String? = nil,
            state: String? = nil,
            street1: String? = nil,
            street2: String? = nil,
            postalCode: String? = nil
        ) {
            self.name = name
            self.number = number
            self.expirationMonth = expirationMonth
            self.expirationYear = expirationYear
            self.securityCode = securityCode
            self.phoneNumber = phoneNumber
            self.email = email
            self.countryCode = countryCode
            self.city = city
            self.postalCode = postalCode
            self.state = state
            self.street1 = street1
            self.street2 = street2
        }
    }
}

extension CreateTokenPayload.Card: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case number
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case securityCode = "security_code"
        case phoneNumber = "phone_number"
        case email = "email"
        case countryCode = "country"
        case city
        case postalCode = "postal_code"
        case state
        case street1
        case street2
    }
}
