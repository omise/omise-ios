import Foundation

struct AuthResponse: Codable {
    var serverStatus: String
    var ares: ARes?
    
    private enum CodingKeys: String, CodingKey {
        case serverStatus = "status"
        case ares
    }
    
    enum Status {
        case challenge
        case failed
        case success
        case unknown
    }
    
    struct ARes: Codable {
        var threeDSServerTransID: String
        var acsTransID: String
        var acsSignedContent: String?
        var acsUIType: String?
        var acsReferenceNumber: String?
        var sdkTransID: String
    }
    
    var status: Status {
        switch serverStatus {
        case "success": return .success
        case "challenge": return .challenge
        case "failed": return .failed
        default: return .unknown
        }
    }
}
