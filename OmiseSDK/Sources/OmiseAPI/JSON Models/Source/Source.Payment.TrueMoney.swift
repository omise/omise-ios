import Foundation

extension Source.Payment {
    /// Payment for `TrueMoney Wallet` payment method
    /// https://docs.opn.ooo/truemoney-wallet
    public struct TrueMoneyWallet: Equatable {
        /// Phone number
        public let phoneNumber: String
    }
}

extension Source.Payment.TrueMoneyWallet: SourceTypeContainerProtocol {
    /// Source payment method identifier
    static let sourceType: SourceType = .trueMoneyWallet
    var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.Payment.TrueMoneyWallet: Codable {
    private enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
    }
}
