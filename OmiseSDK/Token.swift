import Foundation


public struct CreateTokenParameter: Encodable {
    /// Card holder's full name.
    public let name: String
    /// Card number.
    public let number: String
    /// Card expiration month (1-12)
    public let expirationMonth: Int
    /// Card expiration year (Gregorian)
    public let expirationYear: Int
    /// Security code (CVV, CVC, etc) printed on the back of the card.
    public let securityCode: String
    /// Issuing city.
    public let city: String?
    /// Postal code.
    public let postalCode: String?
    
    /// Initializes new token request.
    public init(name: String, number: String, expirationMonth: Int, expirationYear: Int,
                securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.name = name
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.city = city
        self.postalCode = postalCode
    }
}

public struct Token: Object {
    public typealias CreateParameter = CreateTokenParameter
    
    public static let postURL: URL = URL(string: "https://vault.omise.co/tokens")!
    
    public let object: String
    public let id: String
    
    public let isLiveMode: Bool
    
    public let location: String
    public var isUsed: Bool
    
    public let card: Card
    
    public let createdDate: Date
}

public struct Card: Decodable {
    /// Card's ID.
    public let id: String
    /// Boolean flag indicating wether this card is a live card or a test card.
    public let isLiveMode: Bool
    /// Resource URL that can be used to re-load card information.
    public let location: String
    /// Card's creation time.
    public let createdDate: Date
    /// ISO3166 Country code based on the card number.
    /// - note: This is informational only and may not always be 100% accurate.
    public let country: String?
    /// Issuing city.
    /// - note: This is informational only and may not always be 100% accurate.
    public let city: String?
    /// Postal code.
    public let postalCode: String?
    /// Credit card financing type. (debit or credit)
    public let financing: String?
    /// Last 4 digits of the card number.
    public let lastDigits: String
    /// Card brand. (e.g. Visa, Mastercard, ...)
    public let brand: String?
    /// Card expiration month (1-12)
    public let expirationMonth: Int?
    /// Card expiration year (Gregrorian)
    public let expirationYear: Int?
    /// Unique card-based fingerprint. Allows detection of identical cards without
    /// exposing card numbers directly.
    public let fingerprint: String?
    /// Card holder's full name.
    public let name: String?
    public let securityCodeCheck: Bool = false
    
}


