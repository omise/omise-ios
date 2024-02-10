import Foundation

protocol APIProtocol {
    var omiseAPIVersion: String { get }
    var server: ServerType { get }
    var path: String { get }
    var method: String { get }
    var contentType: String { get }
    var dateFormatter: DateFormatter { get }
}

enum ServerType {
    case api
    case vault

    // swiftlint:disable force_unwrapping
    var url: URL {
        switch self {
        case .api: return URL(string: "https://api.omise.co")!
        case .vault: return URL(string: "https://vault.omise.co")!
        }
    }
    // swiftlint:enable force_unwrapping
}

enum OmiseAPI {
    case capability
    case token(tokenID: String)
    case createToken(cardInfo: String)
    case createSource(paymentInfo: String)
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

    var method: String {
        switch self {
        case .capability, .token:
            return "GET"
        case .createToken, .createSource:
            return "POST"
        }
    }

    var contentType: String {
        "application/json; charset=utf8"
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }
}

// extension ClientNew.API: NetworkAPIProtocol {
//    var urlRequest: URLRequest {
//        return URLRequest(url: url)
//    }
// }
