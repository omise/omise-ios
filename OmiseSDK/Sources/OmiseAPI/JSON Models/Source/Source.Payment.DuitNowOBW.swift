import Foundation
import UIKit

extension Source.Payment {
    /// Payment for `DuitNow Online Banking/Wallets` payment method
    /// https://docs.omise.co/duitnow-obw
    public struct DuitNowOBW: Equatable {
        /// Bank code selected by customer
        public let bank: Bank

        /// Creates a new DuitNowOBW payment method payload
        ///
        /// - Parameters:
        ///   - bank: Bank code selected by customer
        public init(bank: Bank) {
            self.bank = bank
        }

        /// Convenient static function to create a new DuitNowOBW instance
        static func bank(_ bank: Bank) -> Self {
            Self(bank: bank)
        }
    }
}

/// Payment method identifier
extension Source.Payment.DuitNowOBW: SourceTypeContainerProtocol {
    public static let sourceType: SourceType = .duitNowOBW
    public var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.Payment.DuitNowOBW: Codable {
    // Decode DuitNowOBW object from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bank = try container.decode(Bank.self, forKey: .bank)
    }
}
