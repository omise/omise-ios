import Foundation

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

public enum Environment {
    case dev(vaultURL: URL, apiURL: URL)
    case production
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
