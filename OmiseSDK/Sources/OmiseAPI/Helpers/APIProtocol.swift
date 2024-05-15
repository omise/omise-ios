import Foundation

protocol APIProtocol {
    var omiseAPIVersion: String { get }
    var server: OmiseServerType { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: ContentType { get }
    var dateFormatter: DateFormatter { get }
    var httpBody: Data? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum ContentType: String {
    case json = "application/json; charset=utf8"
}

enum HTTPHeaders: String {
    case authorization = "Authorization"
    case userAgent = "User-Agent"
    case contentType = "Content-Type"
    case omiseVersion = "Omise-Version"
}
