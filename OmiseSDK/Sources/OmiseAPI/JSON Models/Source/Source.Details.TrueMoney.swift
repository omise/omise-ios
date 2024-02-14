import Foundation

extension Source.Details {
    /// Payment for `TrueMoney Wallet` payment method
    /// https://docs.opn.ooo/truemoney-wallet
    public struct TrueMoneyWallet: Equatable {
        /// Alipay barcode number
        public let phoneNumber: String
    }
}

extension Source.Details.TrueMoneyWallet: SourceTypeDetailsProtocol {
    /// Source payment method identifier
    static let sourceType: SourceType = .trueMoneyWallet
    var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.Details.TrueMoneyWallet: Codable {
    private enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
    }
}
