import Foundation


public protocol OmiseObject: Decodable {
    associatedtype CreateParameter: Encodable
    var object: String { get }
    var id: String { get }
}
