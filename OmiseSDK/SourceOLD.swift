import Foundation

/// Represents an Omise SourceOLD object
public struct SourceOLD: CreatableObject {
    public typealias CreateParameter = CreateSourceParameter
    
    public static let postURL: URL = Configuration.default.environment.sourceURL
    
    public let object: String
    /// Omise SourceOLD ID
    public let id: String
    
    /// The payment information of this source describes how the payment is processed
    public let paymentInformation: PaymentInformation
    
    /// Processing Flow of this source
    /// - SeeAlso: Flow
    public let flow: Flow
    
    /// Payment amount of this SourceOLD
    public let amount: Int64
    /// Payment currency of this SourceOLD
    public let currency: Currency
    
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case flow
        case currency
        case amount
        case platformType = "platform_type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paymentInformation = try PaymentInformation(from: decoder)
        object = try container.decode(String.self, forKey: .object)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
        currency = try container.decode(Currency.self, forKey: .currency)
        amount = try container.decode(Int64.self, forKey: .amount)
    }
}

/// Parameter for creating a new `SourceOLD`
/// - SeeAlso: SourceOLD
public struct CreateSourceParameter: Encodable {
    /// The payment information that is used to create a new SourceOLD
    public let paymentInformation: PaymentInformation
    /// The amount of the creating SourceOLD
    public let amount: Int64
    /// The currench of the creating SourceOLD
    public let currency: Currency
    
    private let platformType: String

    // Atome required fields
    private let shippingAddress: PaymentInformation.Atome.ShippingAddress?
    private let items: [PaymentInformation.Atome.Item]?
    private let phoneNumber: String?
    private let name: String?
    private let email: String?

    private enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case platformType = "platform_type"
        case shippingAddress = "shipping"
        case items
        case name
        case email
        case phoneNumber = "phone_number"

    }
    
    /// Create a new `Create SourceOLD Parameter` that will be used to create a new SourceOLD
    ///
    /// - Parameters:
    ///   - paymentInformation: The payment informaiton of the creating SourceOLD
    ///   - amount: The amount of the creating SourceOLD
    ///   - currency: The currency of the creating SourceOLD
    public init(paymentInformation: PaymentInformation, amount: Int64, currency: Currency) {
        self.paymentInformation = paymentInformation
        self.amount = amount
        self.currency = currency
        self.platformType = "IOS"

        if let atomeData = paymentInformation.atomeData {
            shippingAddress = atomeData.shippingAddress
            items = atomeData.items
            name = atomeData.name
            email = atomeData.email
            phoneNumber = atomeData.phoneNumber

        } else {
            shippingAddress = nil
            items = nil
            name = nil
            email = nil
            phoneNumber = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try container.encode(platformType, forKey: .platformType)
        try container.encode(shippingAddress, forKey: .shippingAddress)
        try container.encode(items, forKey: .items)
        try container.encode(name, forKey: .name)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try paymentInformation.encode(to: encoder)
    }
}

/// The processing flow of a SourceOLD
///
/// - redirect: The customer need to be redirected to another URL in order to process the source
/// - offline: The customer need to do something in offline in order to process the source
/// - other: Other processing flow
public enum Flow: RawRepresentable, Decodable, Equatable {
    case redirect
    case offline
    case appRedirect
    case other(String)
    
    public typealias RawValue = String
    
    public var rawValue: String {
        switch self {
        case .offline:
            return "offline"
        case .redirect:
            return "redirect"
        case .appRedirect:
            return "app_redirect"
        case .other(let value):
            return value
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let flow = try container.decode(String.self)
        self.init(rawValue: flow)! // swiftlint:disable:this force_unwrapping
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "redirect":
            self = .redirect
        case "offline":
            self = .offline
        case "app_redirect":
            self = .appRedirect
        default:
            self = .other(rawValue)
        }
    }
}
