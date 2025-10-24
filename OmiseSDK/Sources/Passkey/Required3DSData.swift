import Foundation

public enum Required3DSData {
    case none
    case phoneNumber
    case email
    case all
    
    var shouldRenderEmailField: Bool {
        self == .all || self == .email
    }
    
    var shouldRenderPhoneField: Bool {
        self == .all || self == .phoneNumber
    }
    
    var parsedArgument: [String]? {
        switch self {
        case .none:
            return nil
        case .email:
            return ["email"]
        case .phoneNumber:
            return ["phoneNumber"]
        case .all:
            return ["email", "phoneNumber"]
        }
    }
}
