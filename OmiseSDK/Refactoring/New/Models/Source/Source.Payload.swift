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
        /// TrueMoney Wallet
        case trueMoneyWallet(_ payload: TrueMoneyWallet)
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
            case .trueMoneyWallet(let payload):
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
            case .trueMoneyWallet:
                return .trueMoneyWallet
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
            case .eContext:
                self = try .eContext(EContext(from: decoder))
            case _ where Installment.sourceTypes.contains(sourceType):
                self = try .installment(Installment(from: decoder))
            case .trueMoneyWallet:
                self = try .trueMoneyWallet(TrueMoneyWallet(from: decoder))
            default:
                self = .other(sourceType)
            }
        }
    }
}
