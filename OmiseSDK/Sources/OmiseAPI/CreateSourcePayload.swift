import Foundation

/// Information to create payment source
/// Sources are methods for accepting payments through non-credit-card channels
public struct CreateSourcePayload: Equatable {
    /// Source amount in smallest unit of source currency
    let amount: Int64
    /// Currency for source as three-letter ISO 4217 code
    let currency: String
    /// The payment details of this source describes how the payment is processed
    let details: PaymentInformation
    /// Current SDK platform type
    let platform = "IOS"

    init(amount: Int64, currency: String, details: PaymentInformation) {
        self.amount = amount
        self.currency = currency
        self.details = details
    }
}

extension CreateSourcePayload: Codable {
    private enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case platform = "platform_type"
    }

    /// Encode information to create payment source to JSON string
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(platform, forKey: .platform)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try details.encode(to: encoder)
    }

    // Decode CreateSourcePayload object from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Int64.self, forKey: .amount)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.details = try PaymentInformation(from: decoder)
    }
}
