import Foundation

let OmiseErrorDomain = "co.omise"

public enum OmiseErrorKey: String {
    case Location
    case Code
    case Message
}

public class OmiseError {
    public var location: String?
    public var code: String?
    public var message: String?
    
    var error: NSError {
        guard let code = self.code, let message = self.message, let location = self.message else {
            let userInfo: [NSObject: AnyObject] = [
                NSLocalizedDescriptionKey :  NSLocalizedString("UnexpectedError", value: "Unexpected error", comment: "")
            ]
            
            return NSError(domain: OmiseErrorDomain, code: 0, userInfo: userInfo)
        }
        
        let userInfo: [NSObject: AnyObject] = [ NSLocalizedDescriptionKey:  NSLocalizedString(code, value: message, comment: ""),
            OmiseErrorKey.Location.rawValue : location,
            OmiseErrorKey.Code.rawValue : code,
            OmiseErrorKey.Message.rawValue : NSLocalizedString(message, comment: "")
        ]
        
        return NSError(domain: OmiseErrorDomain, code: code.hashValue, userInfo: userInfo)
    }
    
    class func UnexpectedError(message: String) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            NSLocalizedDescriptionKey :  NSLocalizedString("UnexpectedError", value: message, comment: "")
        ]
        
        return NSError(domain: OmiseErrorDomain, code: 0, userInfo: userInfo)
    }
    
}