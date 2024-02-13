import Foundation

extension Source.Payload {
    /// Payload for `TrueMoney Wallet` payment method
    /// https://docs.opn.ooo/truemoney-wallet
    public struct TrueMoneyWallet: Codable, Equatable {
        /// Alipay barcode number
        public let phoneNumber: String

        private enum CodingKeys: String, CodingKey {
            case phoneNumber = "phone_number"
        }
    }
}
