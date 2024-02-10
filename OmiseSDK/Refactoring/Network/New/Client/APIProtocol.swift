import Foundation

protocol APIProtocol {
    var omiseAPIVersion: String { get }
    var server: ServerType { get }
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

enum ServerType {
    case api
    case vault
}
