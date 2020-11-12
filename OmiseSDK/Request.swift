import Foundation

public typealias RequestResult<T: Object> = Swift.Result<T, Error>

/// Request object for describing a request with the creating parameters
public struct Request<T: CreatableObject> {
    public typealias Callback = (RequestResult<T>) -> Void
    
    /// Parameter of this request
    public let parameter: T.CreateParameter
    
    public init(parameter: T.CreateParameter) {
        self.parameter = parameter
    }
}

