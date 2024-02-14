import Foundation

public struct Configuration {
    private(set) static var shared = Configuration()
    let environment: Environment

    public init(environment: Environment = .production) {
        self.environment = environment
    }

    public static func setShared(_ config: Configuration) {
        shared = config
    }
}

public enum Environment {
    case dev(vaultURL: URL, apiURL: URL)
    case production
}

extension Environment {
    var customVaultURL: URL? {
        guard case .dev(let vaultURL, _) = self else {
            return nil
        }
        return vaultURL
    }

    var customAPIURL: URL? {
        guard case .dev(_, let apiURL) = self else {
            return nil
        }
        return apiURL
    }
}
