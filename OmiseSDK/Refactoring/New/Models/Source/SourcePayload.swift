import Foundation

// TODO: Add Unit Tests for SourcePayload
// TODO: Add comments to SourcePayload's properties

/// Payment source payloads
// Payment source information
// Sources are methods for accepting payments through non-credit-card channels

public enum SourcePayload: Codable, Equatable {
    /// Atome
    case atome(_ payload: Atome)
    /// Barcode
    case barcode(_ payload: Barcode)
    /// Bill Payment
//    case billPayment(_ payload: SourcePayload.BillPayment)
    /// DuitNow Online Banking/Wallets
//    case duitNowOBW(_ payload: SourcePayload.DoitNowOBW)
    /// Konbini, Pay-easy, and Online Banking
//    case eContext(SourcePayload.EContext)
    /// Malaysia FPX
//    case fpx(SourcePayload.FPX)
    /// Installment Payments
//    case installment(SourcePayload.Installment)
//    case internetBanking(SourcePayload.MobileBanking)
//    case mobileBanking(SourcePayload.MobileBanking)
//    case points(SourcePayload.Points)
//    case trueMoney(SourcePayload.TrueMoney)
    /// Payment menthods without additional payment parameters
    case other(SourceType)

    private enum CodingKeys: String, CodingKey {
        case sourceType = "type"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sourceType, forKey: .sourceType)
        switch self {
        case .atome(let value):
            try value.encode(to: encoder)
        default:
            break
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sourceType = try container.decode(SourceType.self, forKey: .sourceType)
        self = .other(sourceType)
    }
}

extension SourcePayload {
    // TODO: Complete sourceType implementation
    public var sourceType: SourceType {
        switch self {
        case .other(let sourceType):
            return sourceType
        case .barcode(let payload):
            return payload.sourceType
        default:
            return .atome
        }
    }
}
