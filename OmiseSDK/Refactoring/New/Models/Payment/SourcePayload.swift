import Foundation

// TODO: Add Unit Tests for SourcePayload
// TODO: Add comments to SourcePayload's properties
public enum SourcePayload: Codable, Equatable {
    case atome(SourcePayload.Atome)
//    case barcode(SourcePayload.Barcode)
//    case billPayment(SourcePayload.BillPayment)
//    case duitNowOBW(SourcePayload.DoitNowOBW)
//    case eContext(SourcePayload.EContext)
//    case fpx(SourcePayload.FPX)
//    case installment(SourcePayload.Installment)
//    case mobileBanking(SourcePayload.MobileBanking)
//    case points(SourcePayload.Points)
//    case trueMoney(SourcePayload.TrueMoney)
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
        default:
            return .atome
        }
    }
}
