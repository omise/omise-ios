import Foundation

extension OmiseServerType {
    // swiftlint:disable force_unwrapping
    var apiServerURL: String { "https://vault.omise.co" }
    var vaultServerURL: String { "https://vault.omise.co" }

    var url: URL {
        switch self {
        case .api: return URL(string: apiServerURL)!
        case .vault: return URL(string: vaultServerURL)!
        }
    }
    // swiftlint:enable force_unwrapping
}

enum OmiseAPI {
    case capability
    case token(tokenID: String)
    case createToken(payload: CreateTokenPayload)
    case createSource(payload: CreateSourcePayload)
}

extension OmiseAPI: APIProtocol {
    var omiseAPIVersion: String {
        "2019-05-29"
    }

    var server: OmiseServerType {
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
        case .createToken(let payload):
            return try? jsonEncoder.encode(payload)
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
