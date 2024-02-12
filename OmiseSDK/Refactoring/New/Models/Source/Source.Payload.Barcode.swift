import Foundation

extension Source.Payload {
    /// `Barcode` payment methods
    /// https://docs.opn.ooo/alipay-barcode
    public enum Barcode: Codable, Equatable {
        /// Alipay In-Store payment method
        case alipay(_ payload: Alipay)

        fileprivate enum CodingKeys: String, CodingKey {
            case sourceType = "type"
        }
    }
}

public extension Source.Payload.Barcode {
    /// Encoding Billing payment payload to JSON
    func encode(to encoder: Encoder) throws {
        switch self {
        case .alipay(let payload):
            try payload.encode(to: encoder)
        }
    }

    /// Error for invalid source type value during decoding
    struct InvalidSourceTypeError: Error { }

    /// Decoding Billing payment payload from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sourceType = try container.decode(SourceType.self, forKey: .sourceType)
        switch sourceType {
        case .barcodeAlipay:
            self = .alipay(try Alipay(from: decoder))
        default:
            throw InvalidSourceTypeError()
        }
    }
}

extension Source.Payload.Barcode {
    /// Source types Barcode payment method support
    static var sourceTypes: [SourceType] {
        [.barcodeAlipay]
    }

    /// Source type for current Barcode payment
    var sourceType: SourceType {
        switch self {
        case .alipay: return .barcodeAlipay
        }
    }
}
