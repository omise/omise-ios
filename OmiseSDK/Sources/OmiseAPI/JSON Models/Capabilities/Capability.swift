import Foundation

/// Represents Capability JSON object for communication with Omise API
public struct Capability {
    public let countryCode: String
    public let paymentMethods: [Capability.PaymentMethod]
    public let banks: Set<String>
    public let tokenizationMethods: Set<String>
}

extension Capability {
    /// Returns payment information by given Source Type if presents
    func paymentMethod(for sourceType: SourceType) -> Capability.PaymentMethod? {
        paymentMethods.first { method in
            method.name == sourceType.rawValue
        }
    }

    /// Returns payment information for Card payment method if presents
    var cardPaymentMethod: Capability.PaymentMethod? {
        paymentMethods.first { method in
            method.name == "card"
        }
    }

    func availableSourceTypes(_ sourceTypes: [SourceType]) -> [SourceType] {
        paymentMethods
            .compactMap { $0.sourceType }
            .filter { sourceTypes.contains($0) }
    }
}

extension Capability: Codable {
    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
        case paymentMethods = "payment_methods"
        case banks
        case tokenizationMethods = "tokenization_methods"
    }
}
