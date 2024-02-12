import Foundation

extension Source {
    /// Information details about source payment
    public enum Payload: Codable, Equatable {
        /// Atome
        case atome(_ payload: Atome)
        /// Barcode
        case barcode(_ payload: Barcode)
        /// Bill Payment
        case billPayment(_ payload: BillPayment)
        /// DuitNow Online Banking/Wallets
        case duitNowOBW(_ payload: DoitNowOBW)
        /// Konbini, Pay-easy, and Online Banking
        case eContext(_ payload: EContext)
        /// Malaysia FPX
        case fpx(_ payload: FPX)
        /// Installment Payments
        case installment(_ payload: Installment)
        /// Thai Internet Banking
        case internetBanking(_ payload: InternetBanking)
        /// Mobile Banking
        /// 
        case mobileBanking(_ payload: MobileBanking)
        case points(_ payload: Points)
        case trueMoney(_ payload: TrueMoney)
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
            switch sourceType {
            case _ where Barcode.sourceTypes.contains(sourceType):
                self = try .barcode(Barcode(from: decoder))
            default:
                self = .other(sourceType)
            }
        }
    }
}

extension Source.Payload {
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

