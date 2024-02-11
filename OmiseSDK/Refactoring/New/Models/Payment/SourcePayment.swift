import Foundation

// TODO: Add Unit Tests for SourcePayment
// TODO: Add comments to SourcePayment's properties
public struct SourcePayment: Encodable {
    let amount: Int64
    let currency: String
    let details: SourcePayload

    let platform = "IOS"

    init(amount: Int64, currency: String, details: SourcePayload) {
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
