import Foundation

public struct Capability: Codable {
    public let countryCode: String
    public let paymentMethods: [Capability.PaymentMethod]
    public let banks: Set<String>

    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
        case paymentMethods = "payment_methods"
        case banks
    }
}

extension Capability {
    func paymentMethod(for sourceType: SourceType) -> Capability.PaymentMethod? {
        paymentMethods.first { method in
            method.name == sourceType.rawValue
        }
    }

    var cardPaymentMethod: Capability.PaymentMethod? {
        paymentMethods.first { method in
            method.name == "card"
        }
    }
}
