import Foundation

public struct Configuration {
    public let vaultURL: URL
    public let apiURL: URL

    public init(vaultURL: URL, apiURL: URL) {
        self.vaultURL = vaultURL
        self.apiURL = apiURL
    }
}
