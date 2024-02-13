import Foundation

public enum Environment {
    case dev(vaultURL: URL, apiURL: URL)
    case production

    var tokenURL: URL {
        return vaultURL.appendingPathComponent("tokens")
    }

    var sourceURL: URL {
        return apiURL.appendingPathComponent("sources")
    }

    var capabilityURL: URL {
        return apiURL.appendingPathComponent("capability")
    }
}

extension Environment {
    var customVaultURL: URL? {
        switch self {
        case .dev(let vaultURL, _): return vaultURL
        default: return nil
        }
    }

    var customAPIURL: URL? {
        switch self {
        case .dev(_, let apiURL): return apiURL
        default: return nil
        }
    }
}

extension Environment {
    var vaultURL: URL {
        switch self {
        case .dev(let url, _): return url
        // swiftlint:disable:next force_unwrapping
        case .production: return URL(string: "https://vault.omise.co")!
        }
    }
    
    var apiURL: URL {
        switch self {
        case .dev(_, let url): return url
        // swiftlint:disable:next force_unwrapping
        case .production: return URL(string: "https://api.omise.co")!
        }
    }
}

public struct Configuration {
    private(set) static var `default` = Configuration()
    let environment: Environment

    public init(environment: Environment = .production) {
        self.environment = environment
    }

    public static func setDefault(_ config: Configuration) {
        `default` = config
    }
}
