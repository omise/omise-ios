import Foundation

extension CapabilityNew {
    // TODO: Add Unit Tests to PaymentMethod
    // TODO: Add comments to PaymentMethod's properties
    public struct PaymentMethod: Codable {
        public let name: String
        public let currencies: Set<String>
        public let cardBrands: Set<String>?
        public let installmentTerms: Set<Int>?
        public let banks: Set<Bank>?
        private let provider: Provider?

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
