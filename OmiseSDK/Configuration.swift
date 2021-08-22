import Foundation

enum Environment {
    case staging
    case production
        
    // swiftlint:disable force_unwrapping
    private var vaultBaseURL: URL {
        switch self {
        case .staging: return URL(string: "https://vault.staging-omise.co")!
        case .production: return URL(string: "https://vault.omise.co")!
        }
    }
    
    // swiftlint:disable force_unwrapping
    private var apiBaseURL: URL {
        switch self {
        case .staging: return URL(string: "https://api.staging-omise.co")!
        case .production: return URL(string: "https://api.omise.co")!
        }
    }
    
    var tokenURL: URL {
        return vaultBaseURL.appendingPathComponent("tokens")
    }
    
    var sourceURL: URL {
        return apiBaseURL.appendingPathComponent("sources")
    }
    
    var capabilityURL: URL {
        return apiBaseURL.appendingPathComponent("capability")
    }
}

struct Configuration {
    static let `default` = Configuration()
    
    private init() {}
    
    var environment: Environment {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.range(of: "Staging") != nil {
                return .staging
            }
        }
        
        return .production
    }
}
