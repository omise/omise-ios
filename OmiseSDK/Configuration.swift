import Foundation

public enum Environment {
    case dev(vaultURL: URL, apiURL: URL)
    case production

    var netceteraConfigURL: URL {
        return vaultBaseURL.appendingPathComponent("config")
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

private extension Environment {
    var vaultBaseURL: URL {
        switch self {
        case .dev(let url, _): return url
        // swiftlint:disable:next force_unwrapping
        case .production: return URL(string: "https://vault.omise.co")!
        }
    }
    
    var apiBaseURL: URL {
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
