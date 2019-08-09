import Foundation


/// Represents an Omise Source object
public struct Source: CreatableObject {
    public typealias CreateParameter = CreateSourceParameter
   
    public static let postURL: URL = URL(string: "https://api.omise.co/sources")!
    
    public let object: String
    /// Omise Source ID
    public let id: String
    
    /// The payment information of this source describes how the payment is processed
    public let paymentInformation: PaymentInformation
    
    /// Processing Flow of this source
    /// - SeeAlso: Flow
    public let flow: Flow
    
    /// Payment amount of this Source
    public let amount: Int64
    /// Payment currency of this Source
    public let currency: Currency
    
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case flow
        case currency
        case amount
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


/// Parameter for creating a new `Source`
/// - SeeAlso: Source
public struct CreateSourceParameter: Encodable {
    /// The payment information that is used to create a new Source
    public let paymentInformation: PaymentInformation
    /// The amount of the creating Source
    public let amount: Int64
    /// The currench of the creating Source
    public let currency: Currency
    
    private enum CodingKeys: String, CodingKey {
        case amount
        case currency
    }
    
    /// Create a new `Create Source Parameter` that will be used to create a new Source
    ///
    /// - Parameters:
    ///   - paymentInformation: The payment informaiton of the creating Source
    ///   - amount: The amount of the creating Source
    ///   - currency: The currency of the creating Source
    public init(paymentInformation: PaymentInformation, amount: Int64, currency: Currency) {
        self.paymentInformation = paymentInformation
        self.amount = amount
        self.currency = currency
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try paymentInformation.encode(to: encoder)
    }
}

/// The processing flow of a Source
///
/// - redirect: The customer need to be redirected to another URL in order to process the source
/// - offline: The customer need to do something in offline in order to process the source
/// - other: Other processing flow
public enum Flow: RawRepresentable, Decodable, Equatable {
    case redirect
    case offline
    case other(String)
    
    public typealias RawValue = String
    
    public var rawValue: String {
        switch self {
        case .offline:
            return "offline"
        case .redirect:
            return "redirect"
        case .other(let value):
            return value
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let flow = try container.decode(String.self)
        self.init(rawValue: flow)!
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "redirect":
            self = .redirect
        case "offline":
            self = .offline
        default:
            self = .other(rawValue)
        }
    }
}

