import Foundation
import os

/// Network Client to communicate with Omise APIs
public class Client {
    public typealias RequestResultClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void

    let publicKey: String
    var customApiURL: URL?
    var customVaultURL: URL?

    let network: NetworkServiceProtocol
    private let pollingAttemptsCount = 10
    private let pollingTimeInterval = 3

    /// Latest capability loaded with `capability()`
    public private(set) var latestLoadedCapability: Capability?

    /// Creates a new Client item with given public key
    ///
    /// - Parameters:
    ///   - publicKey: Omise public key
    ///   - network: Optional network communication service is used for testing
    ///   - apiURL: Custom URL for Omise API Server is used for testing
    ///   - vaultURL: Custom URL for Omise Vault Server is used for testing
    init(publicKey: String, network: NetworkServiceProtocol, apiURL: URL? = nil, vaultURL: URL? = nil) {
        self.publicKey = publicKey
        self.network = network
        self.customApiURL = apiURL
        self.customVaultURL = vaultURL
    }
    
    /// Perform Capability API Request
    /// - returns Capability
    public func capability(_ completion: @escaping RequestResultClosure<Capability, Error>) {
        performRequest(api: OmiseAPI.capability) { [weak self] (result: Result<Capability, Error>) in
            if let capability = try? result.get() {
                self?.latestLoadedCapability = capability
            }
            completion(result)
        }
    }
    
    /// Sends Create a Source API request with given Payment Payload
    ///
    /// - Parameters:
    ///    - payload: Information required to perform Create a Source API request
    ///    - completion: Returns `Source` object on success and `Error` on request failed
    public func createSource(payload: CreateSourcePayload, _ completion: @escaping RequestResultClosure<Source, Error>) {
        performRequest(api: OmiseAPI.createSource(payload: payload), completion: completion)
    }

    /// Send Create a Token API request with given Card Payment
    ///
    /// - Parameters:
    ///    - payload: Information required to perform Create a Token API request
    ///    - completion: Returns `Token`object  on success and `Error` on request failed
    public func createToken(payload: CreateTokenPayload.Card, _ completion: @escaping RequestResultClosure<Token, Error>) {
        let apiPayload = CreateTokenPayload(card: payload)
        performRequest(api: OmiseAPI.createToken(payload: apiPayload), completion: completion)
    }

    /// Request a Token from API with given Token ID
    ///
    /// - Parameters:
    ///    - tokenID: Token identifier
    ///    - completion: Returns `Token`object  on success and `Error` on request failed
    public func token(tokenID: String, _ completion: @escaping RequestResultClosure<Token, Error>) {
        performRequest(api: OmiseAPI.token(tokenID: tokenID), completion: completion)
    }

    /// Observe Token Charge Status until it changes
    /// Sends API request every `timeInterval` with number of`maxAttempt`attempts.
    ///
    /// - Parameters:
    ///    - tokenID: Token identifier
    ///    - completion: Returns `Token.ChargeStatus`object with token charge status value  on success and `Error` on request failed
    public func observeChargeStatus(tokenID: String, _ completion: @escaping RequestResultClosure<Token.ChargeStatus, Error>) {
        observeUntilChargeStatusIsFinal(
            tokenID: tokenID,
            timeInterval: pollingTimeInterval,
            attemp: 0,
            maxAttempt: pollingAttemptsCount,
            completion
        )
    }
}
