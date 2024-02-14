import Foundation

extension Capability {
    /// Represents Capability.PaymentMethod JSON object for communication with Omise API
    public struct PaymentMethod: Codable, Equatable {
        public let name: String
        public let currencies: Set<String>
        public let cardBrands: Set<String>?
        public let installmentTerms: Set<Int>?
        public let banks: Set<Bank>?
        private let provider: Provider?

        public init(name: String, currencies: Set<String>, cardBrands: Set<String>?, installmentTerms: Set<Int>?, banks: Set<Bank>?, provider: Provider?) {
            self.name = name
            self.currencies = currencies
            self.cardBrands = cardBrands
            self.installmentTerms = installmentTerms
            self.banks = banks
            self.provider = provider
        }

        private enum CodingKeys: String, CodingKey {
            case name
            case currencies
            case installmentTerms = "installment_terms"
            case cardBrands = "card_brands"
            case banks
            case provider
        }

        var isCardType: Bool {
            name == "card"
        }
    }
}
