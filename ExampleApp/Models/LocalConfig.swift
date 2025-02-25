import Foundation
import OmiseSDK

struct LocalConfig: Codable {
    var publicKey: String = "pkey_"

    private let devVaultBaseURL: String?
    private let devApiBaseURL: String?

    var devMode: Bool {
        devVaultBaseURL != nil && devApiBaseURL != nil
    }
    
    var merchantId: String = ""

    init() {
        devVaultBaseURL = nil
        devApiBaseURL = nil
    }

    var configuration: Configuration? {
        if devMode,
           let vaultBaseURLString = devVaultBaseURL,
           let vaultBaseURL = URL(string: vaultBaseURLString),
           let apiBaseURLString = devApiBaseURL,
           let apiBaseURL = URL(string: apiBaseURLString) {
            return .init(vaultURL: vaultBaseURL, apiURL: apiBaseURL)
        } else {
            return nil
        }
    }

    static var `default`: LocalConfig {
        let resource = Bundle.main.url(forResource: "Config.local", withExtension: "plist")
        if let url = resource, let data = try? Data(contentsOf: url) {
            let config = try? PropertyListDecoder().decode(LocalConfig.self, from: data)
            return config ?? LocalConfig()
        } else {
            return LocalConfig()
        }
    }
}
