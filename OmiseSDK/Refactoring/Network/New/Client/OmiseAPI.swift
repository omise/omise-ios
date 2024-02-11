import Foundation

extension ServerType {
    // swiftlint:disable force_unwrapping
    var url: URL {
        switch self {
        case .api: return URL(string: "https://api.omise.co")!
        case .vault: return URL(string: "https://vault.omise.co")!
        }
    }
    // swiftlint:enable force_unwrapping
}

// TODO: Extend it in Unit Test to add Sample Data
enum OmiseAPI {
    case capability
    case token(tokenID: String)
    case createToken(cardPayment: CardPaymentPayload)
    case createSource(sourcePayment: SourcePaymentPayload)
}

extension OmiseAPI: APIProtocol {
    var omiseAPIVersion: String {
        "2019-05-29"
    }

    var server: ServerType {
        switch self {
        case .capability, .createSource:
            return .api
        case .token, .createToken:
            return .vault
        }
    }

    var path: String {
        switch self {
        case .capability:
            return "capability"
        case .token(let tokenID):
            return "tokens/\(tokenID)"
        case .createToken:
            return "tokens"
        case .createSource:
            return "sources"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .capability, .token:
            return .get
        case .createToken, .createSource:
            return .post
        }
    }

    var contentType: ContentType {
        .json
    }

    var httpBody: Data? {
        switch self {
        case .createToken(let cardPayment):
            struct CardPaymentPayloadContainer: Codable {
                let card: CardPaymentPayload
            }

            let token = CardPaymentPayloadContainer(card: cardPayment)
            return try? jsonEncoder.encode(token)
        case .createSource(let sourcePayment):
            return try? jsonEncoder.encode(sourcePayment)
        default:
            return nil
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }
}

extension OmiseAPI {
    var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }
}

