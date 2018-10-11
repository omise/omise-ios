import Foundation


public enum RequestResult<T: Object> {
    case success(T)
    case fail(Error)
}


/// Request object for describing a request with the creating parameters
public struct Request<T: Object> {
    public typealias Callback = (RequestResult<T>) -> Void
    
    /// Parameter of this request
    public let parameter: T.CreateParameter
    
    public init(parameter: T.CreateParameter) {
        self.parameter = parameter
    }
}

