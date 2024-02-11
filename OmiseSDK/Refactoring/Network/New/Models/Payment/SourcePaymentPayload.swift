import Foundation

struct SourcePaymentPayload: Encodable {
    let payloads: [Encodable]

    init(payload: PaymentPayload, additional: Encodable? = nil) {
        self.payloads = [
            payload,
            additional,
            PlatformTypeContainer(platform: "IOS")
        ].compactMap { $0 }
    }

    func encode(to encoder: Encoder) throws {
        for element in payloads {
            try element.encode(to: encoder)
        }
    }
}

private struct PlatformTypeContainer: Codable {
    let platform: String
    enum CodingKeys: String, CodingKey {
        case platform = "platform_type"
    }
}
