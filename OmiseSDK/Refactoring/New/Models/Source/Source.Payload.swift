import Foundation

/// Protocol to unify codebase related to payload enums
protocol SourcePayloadGroupProtocol {
    /// Source types that belong to payment method group
    static var sourceTypes: [SourceType] { get }
    /// Source type of current payment method
//    var sourceType: SourceType { get }
}

extension Source {
    /// Information details about source payment
    public enum Payload: Codable, Equatable {
        /// Atome
        case atome(_ payload: Atome)
        /// Barcode
        case barcodeAlipay(_ payload: BarcodeAlipay)
        /// DuitNow Online Banking/Wallets
        case duitNowOBW(_ payload: DuitNowOBW)
        /// Konbini, Pay-easy, and Online Banking
        case eContext(_ payload: EContext)
        /// Malaysia FPX
        case fpx(_ payload: FPX)
        /// Installment Payments
        case installment(_ payload: Installment)
        /// Thai Internet Banking
        case internetBanking(_ payload: InternetBanking)
        /// Mobile Banking
        case mobileBanking(_ payload: MobileBanking)
        /// TrueMoney Wallet
        case trueMoney(_ payload: TrueMoney)
        /// Payment menthods without additional payment parameters
        case other(_ sourceType: SourceType)

        /// Encode payload to JSON string
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .atome(let payload):
                try payload.encode(to: encoder)
            case .barcodeAlipay(let payload):
                try payload.encode(to: encoder)
            case .duitNowOBW(let payload):
                try payload.encode(to: encoder)
            case .eContext(let payload):
                try payload.encode(to: encoder)
            case .fpx(let payload):
                try payload.encode(to: encoder)
            case .installment(let payload):
                try payload.encode(to: encoder)
            case .internetBanking(let payload):
                try payload.encode(to: encoder)
            case .mobileBanking(let payload):
                try payload.encode(to: encoder)
            case .trueMoney(let payload):
                try payload.encode(to: encoder)
            case .other(let sourceType):
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(sourceType.rawValue, forKey: .sourceType)
            }
        }

        var sourceType: SourceType {
            switch self {
            case .atome:
                return .atome
            case .barcodeAlipay:
                return .barcodeAlipay
            case .duitNowOBW:
                return .duitNowOBW
            case .eContext:
                return .eContext
            case .fpx:
                return .fpx
            case .installment(let value):
                return value.sourceType
            case .internetBanking(let value):
                return value.sourceType
            case .mobileBanking(let value):
                return value.sourceType
            case .trueMoney:
                return .trueMoney
            case .other(let value):
                return value
            }
        }

        private enum CodingKeys: String, CodingKey {
            case sourceType = "type"
        }
        /// Decode payload from JSON string
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let sourceType = try container.decode(SourceType.self, forKey: .sourceType)

            switch sourceType {
            case .atome:
                self = try .atome(Atome(from: decoder))
            case .barcodeAlipay:
                self = try .barcodeAlipay(BarcodeAlipay(from: decoder))
            case .duitNowOBW:
                self = try .duitNowOBW(DuitNowOBW(from: decoder))
            default:
                self = .other(sourceType)
            }
        }
    }
}


extension Source.Payload {
    public struct SourceTypePayload: Codable, Equatable {
        let sourceType: SourceType

        private enum CodingKeys: String, CodingKey {
            case sourceType = "type"
        }
    }
}
