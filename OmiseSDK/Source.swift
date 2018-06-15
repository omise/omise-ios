import Foundation

public struct Source: OmiseObject {
    public typealias CreateParameter = CreateSourceParameter
    
    public let object: String
    public let id: String
    
    public let type: String
    
    public let flow: String
    public var isUsed: Bool
    
    public let amount: Int64
    
    public let currency: String
}

public struct CreateSourceParameter: Encodable {
    public let type: String
    public let amount: Int64
    public let currency: String
}

