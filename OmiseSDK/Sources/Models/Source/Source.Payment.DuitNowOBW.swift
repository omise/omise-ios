import Foundation

extension Source.Payment {
    /// Payment for `DuitNow Online Banking/Wallets` payment method
    /// https://docs.opn.ooo/duitnow-obw
    public struct DuitNowOBW: Codable, Equatable {
        /// Bank code selected by customer
        public let bank: Bank

        /// Creates a new DuitNowOBW payment method payload
        ///
        /// - Parameters:
        ///   - bank: Bank code selected by customer
        public init(bank: Source.Payment.DuitNowOBW.Bank) {
            self.bank = bank
        }

        // Decode DuitNowOBW object from JSON string
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.bank = try container.decode(Bank.self, forKey: .bank)
        }
    }
}

extension Source.Payment.DuitNowOBW {
    /// Bank code selected by customer
    public enum Bank: String, Codable, CaseIterable, CustomStringConvertible {
        public var description: String {
            self.rawValue
        }

        /// Affin Bank
        case affin
        /// Alliance Bank (Personal)
        case alliance
        /// AGRONet
        case agro
        /// AmBank
        case ambank
        /// Bank Islam
        case islam
        /// Bank Muamalat
        case muamalat
        /// Bank Rakyat
        case rakyat
        /// BSN
        case bsn
        /// CIMB Clicks
        case cimb
        /// Hong Leong Bank
        case hongleong
        /// HSBC Bank
        case hsbc
        /// KFH
        case kfh
        /// Maybank2U
        case maybank2u
        /// OCBC Bank
        case ocbc
        /// Public Bank
        case publicBank = "public"
        /// RHB Bank
        case rhb
        /// Standard Chartered
        case sc
        /// UOB Bank
        case uob
    }
}
