import Foundation


public protocol Object: Decodable {
    var object: String { get }
}

public protocol CreatableObject: Object {
    associatedtype CreateParameter: Encodable
    
    static var postURL: URL { get }
    
    var id: String { get }
}
