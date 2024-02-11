import Foundation

public struct PaymentPayload: Codable {
    let sourceType: SourceType
    let amount: Int64
    let currency: String

    init(sourceType: SourceType, amount: Int64, currency: String) {
        self.sourceType = sourceType
        self.amount = amount
        self.currency = currency
    }
    
    private enum CodingKeys: String, CodingKey {
        case sourceType = "type"
        case amount
        case currency
    }
}
