import Foundation
import UIKit

extension PaymentInformation {
    /// Payment for `DuitNow Online Banking/Wallets` payment method
    /// https://docs.opn.ooo/duitnow-obw
    public struct DuitNowOBW: Equatable {
        /// Bank code selected by customer
        public let bank: Bank

        /// Creates a new DuitNowOBW payment method payload
        ///
        /// - Parameters:
        ///   - bank: Bank code selected by customer
        public init(bank: PaymentInformation.DuitNowOBW.Bank) {
            self.bank = bank
        }

        /// Convenient static function to create a new DuitNowOBW instance
        static func bank(_ bank: PaymentInformation.DuitNowOBW.Bank) -> Self {
            Self(bank: bank)
        }
    }
}

/// Payment method identifier
extension PaymentInformation.DuitNowOBW: SourceTypeContainerProtocol {
    public static let sourceType: SourceType = .duitNowOBW
    public var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension PaymentInformation.DuitNowOBW: Codable {
    // Decode DuitNowOBW object from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bank = try container.decode(Bank.self, forKey: .bank)
    }
}

extension PaymentInformation.DuitNowOBW {
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

extension PaymentInformation.DuitNowOBW.Bank {
    var localizedTitle: String {
        switch self {
        case .affin:
            return "Affin Bank"
        case .alliance:
            return "Alliance Bank"
        case .agro:
            return "Agrobank"
        case .ambank:
            return "AmBank"
        case .islam:
            return "Bank Islam"
        case .muamalat:
            return "Bank Muamalat"
        case .rakyat:
            return "Bank Rakyat"
        case .bsn:
            return "Bank Simpanan Nasional"
        case .cimb:
            return "CIMB Bank"
        case .hongleong:
            return "Hong Leong"
        case .hsbc:
            return "HSBC Bank"
        case .kfh:
            return "Kuwait Finance House"
        case .maybank2u:
            return "Maybank"
        case .ocbc:
            return "OCBC"
        case .publicBank:
            return "Public Bank"
        case .rhb:
            return "RHB Bank"
        case .sc:
            return "Standard Chartered"
        case .uob:
            return "United Overseas Bank"
        }
    }
    var listIcon: UIImage? {
        switch self {
        case .affin:
            return UIImage(omise: "FPX/affin")
        case .alliance:
            return UIImage(omise: "FPX/alliance")
        case .agro:
            return UIImage(omise: "agrobank")
        case .ambank:
            return UIImage(omise: "FPX/ambank")
        case .islam:
            return UIImage(omise: "FPX/islam")
        case .muamalat:
            return UIImage(omise: "FPX/muamalat")
        case .rakyat:
            return UIImage(omise: "FPX/rakyat")
        case .bsn:
            return UIImage(omise: "FPX/bsn")
        case .cimb:
            return UIImage(omise: "FPX/cimb")
        case .hongleong:
            return UIImage(omise: "FPX/hong-leong")
        case .hsbc:
            return UIImage(omise: "FPX/hsbc")
        case .kfh:
            return UIImage(omise: "FPX/kfh")
        case .maybank2u:
            return UIImage(omise: "FPX/maybank")
        case .ocbc:
            return UIImage(omise: "FPX/ocbc")
        case .publicBank:
            return UIImage(omise: "FPX/public-bank")
        case .rhb:
            return UIImage(omise: "FPX/rhb")
        case .sc:
            return UIImage(omise: "FPX/sc")
        case .uob:
            return UIImage(omise: "FPX/uob")
        }
    }
}
