import Foundation

extension Source.PaymentInformation {
    /// Payment for `TrueMoney Wallet` payment method
    /// https://docs.opn.ooo/truemoney-wallet
    public struct TrueMoneyWallet: Equatable {
        /// Phone number
        public let phoneNumber: String
    }
}

extension Source.PaymentInformation.TrueMoneyWallet: SourceTypeContainerProtocol {
    /// Source payment method identifier
    static let sourceType: SourceType = .trueMoneyWallet
    var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.PaymentInformation.TrueMoneyWallet: Codable {
    private enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
    }
}
