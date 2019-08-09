import Foundation

#if swift(>=5)
public typealias RequestResult<T: Object> = Swift.Result<T, Error>
#else
public enum RequestResult<T: Object> {
    case success(T)
    case failure(Error)
}
#endif


/// Request object for describing a request with the creating parameters
public struct Request<T: CreatableObject> {
    public typealias Callback = (RequestResult<T>) -> Void
    
    /// Parameter of this request
    public let parameter: T.CreateParameter
    
    public init(parameter: T.CreateParameter) {
        self.parameter = parameter
    }
}

