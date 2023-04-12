import Foundation

enum Environment {
    case staging
    case production
        
    // swiftlint:disable force_unwrapping
    private var vaultBaseURL: URL {
        switch self {
        case .staging: return URL(string: "[STAGING_URL]")!
        case .production: return URL(string: "https://vault.omise.co")!
        }
    }
    
    private var apiBaseURL: URL {
        switch self {
        case .staging: return URL(string: "[STAGING_URL]")!
        case .production: return URL(string: "https://api.omise.co")!
        }
    }

    // swiftlint:enable force_unwrapping

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
    
    private init() {
        // Intentionally empty (SonarCloud warning fix)
    }
    
    var environment: Environment {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.range(of: "Staging") != nil {
                return .staging
            }
        }
        
        return .production
    }
}
