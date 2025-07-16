import Foundation

extension OmiseError.APIErrorCode: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ErrorUserInfoKey.self)
        let codeValue = try container.decode(String.self, forKey: .code)
        let message = try container.decode(String.self, forKey: .message)
        
        switch codeValue {
        case "invalid_card":
            self = .invalidCard(try OmiseError.APIErrorCode.InvalidCardReason.parseInvalidCardReasonsFromMessage(message))
        case "bad_request":
            self = .badRequest(try OmiseError.APIErrorCode.BadRequestReason.parseBadRequestReasonsFromMessage(message, currency: .main))
        case "authentication_failure":
            self = .authenticationFailure
        case "service_not_found":
            self = .serviceNotFound
        default:
            self = .other(codeValue)
        }
    }
}
