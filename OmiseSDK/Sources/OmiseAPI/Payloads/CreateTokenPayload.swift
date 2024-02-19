import Foundation

/// Card Information to create a token container
/// Used as payload in createToken API
public struct CreateTokenPayload: Codable {
    let card: Card

    /// Card Information to create a token
    /// A token represents a credit or debit card
    /// https://docs.opn.ooo/tokens-api
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
        /// Address
        public let address: PaymentInformation.Address?

        public init(name: String, number: String, expirationMonth: Int, expirationYear: Int, securityCode: String, phoneNumber: String? = nil, address: PaymentInformation.Address? = nil) {
            self.name = name
            self.number = number
            self.expirationMonth = expirationMonth
            self.expirationYear = expirationYear
            self.securityCode = securityCode
            self.phoneNumber = phoneNumber
            self.address = address
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
    }

    /// Encode information to create payment source to JSON string
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(expirationMonth, forKey: .expirationMonth)
        try container.encode(expirationYear, forKey: .expirationYear)
        try container.encode(securityCode, forKey: .securityCode)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try address?.encode(to: encoder)
    }

    // Decode CreateSourcePayload object from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(String.self, forKey: .number)
        self.expirationMonth = try container.decode(Int.self, forKey: .expirationMonth)
        self.expirationYear = try container.decode(Int.self, forKey: .expirationYear)
        self.securityCode = try container.decode(String.self, forKey: .securityCode)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.address = try? PaymentInformation.Address(from: decoder)
    }
}
