import Foundation
import os

/// Network Client to communicate with Omise APIs
class Client: ClientProtocol {
    let version: String
    let publicKey: String
    var customApiURL: URL?
    var customVaultURL: URL?

    let network: NetworkServiceProtocol
    private let pollingAttemptsCount = 10
    private let pollingTimeInterval = 3

    /// Latest capability loaded with `capability()`
    private(set) var latestLoadedCapability: Capability?

    /// Creates a new Client item with given public key
    ///
    /// - Parameters:
    ///   - publicKey: Omise public key, should starts with "pkey_"
    ///   - network: Optional network communication service is used for testing
    ///   - apiURL: Custom URL for Omise API Server is used for testing
    ///   - vaultURL: Custom URL for Omise Vault Server is used for testing
    init(publicKey: String, version: String, network: NetworkServiceProtocol = NetworkService(), apiURL: URL? = nil, vaultURL: URL? = nil) {

        if publicKey.hasPrefix("pkey_") {
            self.publicKey = publicKey
        } else {
            self.publicKey = ""
            os_log("Refusing to initialize sdk client with a non-public key: %{private}@", log: sdkLogObject, type: .error, publicKey)
            assertionFailure("Refusing to initialize sdk client with a non-public key.")
        }

        self.version = version
        self.network = network
        self.customApiURL = apiURL
        self.customVaultURL = vaultURL
    }
    
    /// Performs a Capability API Request
    /// - parameter completion: Returns `Capability` object on success and `Error` on request failed
    func capability(_ completion: @escaping ResponseClosure<Capability, Error>) {
        performRequest(api: OmiseAPI.capability) { [weak self] (result: Result<Capability, Error>) in
            if let capability = try? result.get() {
                self?.latestLoadedCapability = capability
            }
            completion(result)
        }
    }
    
    /// Sends `Create a Source` API request with given Payment Payload
    /// - parameter payload: Information required to perform Create a Source API request
    /// - parameter completion: Returns `Source` object on success and `Error` on request failed
    func createSource(payload: CreateSourcePayload, _ completion: @escaping ResponseClosure<Source, Error>) {
        performRequest(api: OmiseAPI.createSource(payload: payload), completion: completion)
    }

    /// Sends `Create a Token` API request with given Card Payment
    /// - parameter payload: Information required to perform Create a Token API request
    /// - parameter completion: Returns `Token`object  on success and `Error` on request failed
    func createToken(payload: CreateTokenPayload, _ completion: @escaping ResponseClosure<Token, Error>) {
        performRequest(api: OmiseAPI.createToken(payload: payload), completion: completion)
    }
    
    func createToken(applePayToken: CreateTokenApplePayPayload, _ completion: @escaping ResponseClosure<Token, Error>) {
        performRequest(api: OmiseAPI.createTokenFromApplePayToken(token: applePayToken), completion: completion)
    }

    /// Requests a `Token` from API with given Token ID
    /// - parameter tokenID: Token identifier
    /// - parameter completion: Returns `Token`object  on success and `Error` on request failed
    func token(tokenID: String, _ completion: @escaping ResponseClosure<Token, Error>) {
        performRequest(api: OmiseAPI.token(tokenID: tokenID), completion: completion)
    }

    /// Observes `Token Charge Status` until it changes or max attempts is reached
    /// - parameter tokenID: Token identifier
    /// - parameter completion: Returns `Token.ChargeStatus`object with token charge status value  on success and `Error` on request failed
    func observeChargeStatus(tokenID: String, _ completion: @escaping ResponseClosure<Token.ChargeStatus, Error>) {
        observeUntilChargeStatusIsFinal(
            tokenID: tokenID,
            timeInterval: pollingTimeInterval,
            attemp: 0,
            maxAttempt: pollingAttemptsCount,
            completion
        )
    }
}

// For Unit Testing
extension Client {
    func setLatestLoadedCapability(_ capability: Capability?) {
        latestLoadedCapability = capability
    }
}
