import Foundation

/// Protocol to group payment methods by it's source type
protocol SourceTypeContainerProtocol: Codable {
    static var sourceType: SourceType { get }
    var sourceType: SourceType { get }
}

extension Source {
    /// Information details about source payment
    /// There are some payment methods that has additional parameters like "phoneNumber" and some requires only Source`type`
    /// This enum groups all supported payment methods details together.
    public enum Payment: Equatable {
        /// Atome
        case atome(_ details: Atome)
        /// Barcode
        case barcodeAlipay(_ details: BarcodeAlipay)
        /// DuitNow Online Banking/Wallets
        case duitNowOBW(_ details: DuitNowOBW)
        /// Konbini, Pay-easy, and Online Banking
        case eContext(_ payloadetailsd: EContext)
        /// Malaysia FPX
        case fpx(_ details: FPX)
        /// Installment Payments
        case installment(_ details: Installment)
        /// TrueMoney Wallet
        case trueMoneyWallet(_ details: TrueMoneyWallet)
        /// Payment menthods without additional payment parameters
        case sourceType(_ sourceType: SourceType)

        /// SourceType of current payment
        /// Used for encoding sourceType parameter into flat JSON string
        public var sourceType: SourceType {
            switch self {
            case .sourceType(let sourceType): return sourceType
            case .atome(let details): return details.sourceType
            case .barcodeAlipay(let details): return details.sourceType
            case .duitNowOBW(let details): return details.sourceType
            case .eContext(let details): return details.sourceType
            case .fpx(let details): return details.sourceType
            case .installment(let details): return details.sourceType
            case .trueMoneyWallet(let details): return details.sourceType
            }
        }
    }
}

/// Encoding/decoding JSON string
extension Source.Payment: Codable {
    private enum CodingKeys: String, CodingKey {
        case sourceType = "type"
    }

    /// Encodes Source information and additional details if presents into JSON string
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .atome(let details as Encodable),
                .barcodeAlipay(let details as Encodable),
                .duitNowOBW(let details as Encodable),
                .eContext(let details as Encodable),
                .fpx(let details as Encodable),
                .installment(let details as Encodable),
                .trueMoneyWallet(let details as Encodable):
            try details.encode(to: encoder)
        default:
            break
        }
        try container.encode(sourceType, forKey: .sourceType)
    }

    /// Creates new instance from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sourceType = try container.decode(SourceType.self, forKey: .sourceType)

        switch sourceType {
        case Atome.sourceType:
            self = try .atome(Atome(from: decoder))
        case BarcodeAlipay.sourceType:
            self = try .barcodeAlipay(BarcodeAlipay(from: decoder))
        case DuitNowOBW.sourceType:
            self = try .duitNowOBW(DuitNowOBW(from: decoder))
        case EContext.sourceType:
            self = try .eContext(EContext(from: decoder))
        case TrueMoneyWallet.sourceType:
            self = try .trueMoneyWallet(TrueMoneyWallet(from: decoder))
        case FPX.sourceType:
            self = try .fpx(FPX(from: decoder))
        case _ where sourceType.isInstallment:
            self = try .installment(Installment(from: decoder))
        default:
            self = .sourceType(sourceType)
        }
    }
}

extension Source.Payment {
    static func requiresAdditionalDetails(sourceType: SourceType) -> Bool {
        let requiresDetails: [SourceType] = [
            Atome.sourceType,
            BarcodeAlipay.sourceType,
            DuitNowOBW.sourceType,
            EContext.sourceType,
            TrueMoneyWallet.sourceType,
            FPX.sourceType
        ] + SourceType.installments

        return requiresDetails.contains(sourceType)
    }
}
