import Foundation

extension PaymentInformation {
    /// Payment for Malaysia FPX payment method
    /// https://docs.opn.ooo/fpx
    public struct FPX: Equatable {
        /// Bank code selected by customer
        public let bank: Bank
        /// Customer email
        public let email: String?

        /// Creates a new FPX payment method payload
        ///
        /// - Parameters:
        ///   - bank: Bank code selected by customer
        ///   - email: Customer email
        public init(bank: PaymentInformation.FPX.Bank, email: String?) {
            self.bank = bank
            self.email = email
        }

        /// Convenient static function to create a new DuitNowOBW instance
        static func bank(_ bank: PaymentInformation.FPX.Bank, email: String?) -> Self {
            Self(bank: bank, email: email)
        }
    }
}

extension PaymentInformation.FPX: SourceTypeContainerProtocol {
    /// Source payment method identifier
    static let sourceType: SourceTypeValue = .fpx
    var sourceType: SourceTypeValue { Self.sourceType }
}

/// Encoding/decoding JSON string
extension PaymentInformation.FPX: Codable {
    /// Decode DuitNowOBW object from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bank = try container.decode(Bank.self, forKey: .bank)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
    }
}

extension PaymentInformation.FPX {
    /// Bank code selected by customer
    public enum Bank: String, Codable {
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
        /// Bank Of China
        case bocm
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
        /// Maybank2E
        case maybank2e
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
