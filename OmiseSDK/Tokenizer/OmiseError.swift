import Foundation

let OmiseErrorDomain = "co.omise"

public enum OmiseErrorCode: Int {
    case InvalidRequestError = 50
    case APIError = 60
    case UnexpectedError = 70
}

public class OmiseError {
    public var location: String?
    public var code: String?
    public var message: String?
    
    class func ErrorFromResponse(error: OmiseError) -> NSError {
        guard let code = error.code, let message = error.message else {
            let userInfo: [NSObject: AnyObject] =
                [ NSLocalizedDescriptionKey :  NSLocalizedString("UnexpectedError", value: "Unexpected error", comment: "") ]
            
            return NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.UnexpectedError.rawValue, userInfo: userInfo)
        }
        
        var errorCode = 0
        
        let userInfo: [NSObject: AnyObject] =
            [ NSLocalizedDescriptionKey:  NSLocalizedString(code, value: message, comment: "") ]
        
        switch code {
        case "authentication_failure", "invalid_card":
            errorCode = OmiseErrorCode.InvalidRequestError.rawValue
            break
        default:
            errorCode = OmiseErrorCode.APIError.rawValue
            break
        }
        
        return NSError(domain: OmiseErrorDomain, code: errorCode, userInfo: userInfo)
        
    }
    
    class func UnexpectedError(message: String) -> NSError {
        let userInfo: [NSObject: AnyObject] =
            [ NSLocalizedDescriptionKey :  NSLocalizedString("UnexpectedError", value: message, comment: "") ]
        
        return NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.UnexpectedError.rawValue, userInfo: userInfo)
    }
    
}