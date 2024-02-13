import Foundation

extension Source.Payment {
    /// Payment for `TrueMoney Wallet` payment method
    /// https://docs.opn.ooo/truemoney-wallet
    public struct TrueMoneyWallet: Codable, Equatable {
        /// Alipay barcode number
        public let phoneNumber: String

        private enum CodingKeys: String, CodingKey {
            case phoneNumber = "phone_number"
        }
    }
}
