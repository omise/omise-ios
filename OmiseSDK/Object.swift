import Foundation


public protocol Object: Decodable {
    associatedtype CreateParameter: Encodable
    
    static var postURL: URL { get }
    
    var object: String { get }
    var id: String { get }
}
