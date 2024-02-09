import Foundation

// TODO: Add comments for public properties and functions
extension CapabilityNew {
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
    }
}

extension CapabilityNew.PaymentMethod {
    enum PaymentMethodType {
        case card
        case source(SourceType)
        case unsupported(paymentMethod: String)
    }
    
    var type: PaymentMethodType {
        if let sourceType = SourceType(rawValue: name) {
            return .source(sourceType)
        } else if isCardType {
            return .card
        } else {
            return .unsupported(paymentMethod: name)
        }
    }

    var isCardType: Bool {
        name == "card"
    }
}

private extension CapabilityNew.PaymentMethod {
    enum Provider: String, Codable, Hashable {
        case alipayPlus = "Alipay_plus"
        case rms = "RMS"
        case unknown

        init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
