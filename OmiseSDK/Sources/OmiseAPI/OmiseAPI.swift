import Foundation

enum OmiseServerType {
    case api
    case vault
    case other(baseURL: URL)
}

extension OmiseServerType {
    // swiftlint:disable force_unwrapping
    private var apiServerURL: String { "https://vault.omise.co" }
    private var vaultServerURL: String { "https://vault.omise.co" }
    
    var url: URL {
        switch self {
        case .api: return URL(string: apiServerURL)!
        case .vault: return URL(string: vaultServerURL)!
        case .other(let url): return url
        }
    }
    // swiftlint:enable force_unwrapping
}

enum OmiseAPI {
    case capability
    case token(tokenID: String)
    case createToken(payload: CreateTokenPayload)
    case createSource(payload: CreateSourcePayload)
    case netceteraConfig(baseUrl: URL)
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
        case .netceteraConfig(let baseURL):
            return .other(baseURL: baseURL)
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
        case .netceteraConfig:
            return "config"
        }
    }

    var url: URL {
        server.url.appendingLastPathComponent(path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .capability, .token:
            return .get
        case .createToken, .createSource:
            return .post
        case .netceteraConfig:
            return .get
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
