//
//  LocalConfig.swift
//  ExampleApp (Swift)
//
//  Created by Andrei Solovev on 10/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import OmiseSDK

struct LocalConfig: Codable {
    var publicKey: String = "pkey_"

    private let devVaultBaseURL: String?
    private let devApiBaseURL: String?

    var devMode: Bool {
        devVaultBaseURL != nil && devApiBaseURL != nil
    }

    init() {
        devVaultBaseURL = nil
        devApiBaseURL = nil
    }
    
    var env: Environment {
        if devMode,
           let vaultBaseURLString = devVaultBaseURL,
           let vaultBaseURL = URL(string: vaultBaseURLString),
           let apiBaseURLString = devApiBaseURL,
           let apiBaseURL = URL(string: apiBaseURLString) {
            return .dev(vaultURL: vaultBaseURL, apiURL: apiBaseURL)
        } else {
            return .production
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
