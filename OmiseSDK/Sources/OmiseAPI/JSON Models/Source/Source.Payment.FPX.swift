import Foundation

extension Source.Payment {
    /// Payment for Malaysia FPX payment method
    /// https://docs.opn.ooo/fpx
    public struct FPX: Equatable {
        /// Bank code selected by customer
        public let bank: String
        /// Customer email
        public let email: String?

        /// Creates a new FPX payment method payload
        ///
        /// - Parameters:
        ///   - bank: Bank code selected by customer
        ///   - email: Customer email
        public init(bank: String, email: String?) {
            self.bank = bank
            self.email = email
        }

        /// Convenient static function to create a new DuitNowOBW instance
        static func bank(_ bank: String, email: String?) -> Self {
            Self(bank: bank, email: email)
        }
    }
}

extension Source.Payment.FPX: SourceTypeContainerProtocol {
    /// Source payment method identifier
    static let sourceType: SourceType = .fpx
    var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.Payment.FPX: Codable {
    /// Decode DuitNowOBW object from JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bank = try container.decode(String.self, forKey: .bank)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
    }
}
