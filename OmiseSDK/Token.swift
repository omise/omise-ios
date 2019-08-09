import Foundation


/// Parameter for creating a new `Token`
/// - seealso: Token
public struct CreateTokenParameter: Encodable {
    /// Card holder's full name.
    public let name: String
    /// Card number.
    public let pan: PAN
    
    /// Masked PAN number
    public var number: String {
        return pan.number
    }
    
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
    
    private enum TokenCodingKeys: String, CodingKey {
        case card
        
        enum CardCodingKeys: String, CodingKey {
            case number
            case name
            case expirationMonth = "expiration_month"
            case expirationYear = "expiration_year"
            case securityCode = "security_code"
            case city
            case postalCode = "postal_code"
        }
    }
    
    
    /// Initializes new token request.
    public init(name: String, pan: PAN, expirationMonth: Int, expirationYear: Int,
                securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.name = name
        self.pan = pan
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.city = city
        self.postalCode = postalCode
    }
    
    /// Initializes a new token request.
    public init(name: String, number: String, expirationMonth: Int, expirationYear: Int,
                securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.init(name: name, pan: PAN(number), expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: securityCode, city: city, postalCode: postalCode)
    }
    
    public func encode(to encoder: Encoder) throws {
        var tokenContainer = encoder.container(keyedBy: TokenCodingKeys.self)
        var cardContainer = tokenContainer.nestedContainer(keyedBy: TokenCodingKeys.CardCodingKeys.self, forKey: .card)
        
        try cardContainer.encode(pan.pan, forKey: .number)
        try cardContainer.encodeIfPresent(name, forKey: .name)
        try cardContainer.encodeIfPresent(expirationMonth, forKey: .expirationMonth)
        try cardContainer.encodeIfPresent(expirationYear, forKey: .expirationYear)
        try cardContainer.encodeIfPresent(securityCode, forKey: .securityCode)
        try cardContainer.encodeIfPresent(city, forKey: .city)
        try cardContainer.encodeIfPresent(postalCode, forKey: .postalCode)
    }
}


/// Represents an Omise Token object
public struct Token: CreatableObject {
    public typealias CreateParameter = CreateTokenParameter
    
    public static let postURL: URL = URL(string: "https://vault.omise.co/tokens")!
    
    public let object: String
    /// Omise ID of the token
    public let id: String
    
    /// Boolean indicates that if this Token is in the live mode
    public let isLiveMode: Bool
    
    /// URL for fetching the Token data
    public let location: String
    /// Boolean indicates that if this token is already used for creating a charge already
    public var isUsed: Bool
    
    /// Card that is used for creating this Token
    public let card: Card
    
    /// Date that this Token was created
    public let createdDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case object
        case location
        case id
        case createdDate = "created_at"
        case isLiveMode = "livemode"
        case isUsed = "used"
        case card
    }
}


public struct Card: Decodable {
    /// Card's ID.
    public let id: String
    /// Boolean flag indicating wether this card is a live card or a test card.
    public let isLiveMode: Bool
    /// Card's creation time.
    public let createdDate: Date
    /// ISO3166 Country code based on the card number.
    /// - note: This is informational only and may not always be 100% accurate.
    public let countryCode: String?
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
    /// Boolean indicates that whether that the card is passed the security code check
    public let securityCodeCheck: Bool
    
    public let bankName: String?
    public let object: String
    
    private enum CodingKeys: String, CodingKey {
        case object
        case id
        case isLiveMode = "livemode"
        case createdDate = "created_at"
        case lastDigits = "last_digits"
        case brand
        case name
        case bankName = "bank"
        case postalCode = "postal_code"
        case countryCode = "country"
        case city
        case financing
        case fingerprint
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case securityCodeCheck = "security_code_check"
    }
}


extension Calendar {
    /// Calendar used in the Credit Card information which is Gregorian Calendar
    public static let creditCardInformationCalendar: Calendar = Calendar(identifier: .gregorian)
    /// Range contains the valid range of the expiration month value
    public static let validExpirationMonthRange: Range<Int> = Calendar.creditCardInformationCalendar.maximumRange(of: .month)!
}

extension NSCalendar {
    /// Calendar used in the Credit Card information which is Gregorian Calendar
    @objc(creditCardInformationCalendar) public static var __creditCardInformationCalendar: Calendar {
        return Calendar.creditCardInformationCalendar
    }
}


extension Request where T == Token {
    
    /// Initializes a new Token Request with the given information
    public init (name: String, pan: PAN, expirationMonth: Int, expirationYear: Int,
                 securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.init(parameter: CreateTokenParameter(
            name: name, pan: pan,
            expirationMonth: expirationMonth, expirationYear: expirationYear,
            securityCode: securityCode,
            city: city, postalCode: postalCode
        ))
    }
    
    /// Initializes a new Token Request with the given information
    public init (name: String, number: String, expirationMonth: Int, expirationYear: Int,
                 securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.init(parameter: CreateTokenParameter(
            name: name, number: number,
            expirationMonth: expirationMonth, expirationYear: expirationYear,
            securityCode: securityCode,
            city: city, postalCode: postalCode
        ))
    }
}

