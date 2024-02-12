import Foundation

// TODO: Add Unit Tests for SourcePayment
// TODO: Add comments to SourcePayment's properties

/// Information to create payment Source
/// Sources are methods for accepting payments through non-credit-card channels
public struct SourcePayment: Encodable {
    /// Source amount in smallest unit of source currency
    let amount: Int64
    /// Currency for source as three-letter ISO 4217 code
    let currency: String
    let details: Source.Payload

    let platform = "IOS"

    init(amount: Int64, currency: String, details: Source.Payload) {
        self.amount = amount
        self.currency = currency
        self.details = details
    }

    private enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case platform = "platform_type"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(platform, forKey: .platform)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try details.encode(to: encoder)
    }
}
