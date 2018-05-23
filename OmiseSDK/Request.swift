import Foundation


public enum RequestResult<T: Object> {
    case success(T)
    case fail(Error)
}

public struct Request<T: Object> {
    public typealias Callback = (RequestResult<T>) -> Void
    
    public let parameter: T.CreateParameter
    
    public init(parameter: T.CreateParameter) {
        self.parameter = parameter
    }
}

