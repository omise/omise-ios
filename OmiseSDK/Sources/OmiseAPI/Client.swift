import Foundation
import os

/// Network Client to communicate with Omise APIs
public class Client {
    public typealias RequestResultClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void

    let pollingAttemptsCount = 10
    let pollingTimeInterval = 3

    let publicKey: String
    let network: NetworkServiceProtocol

    init(publicKey: String, network: NetworkServiceProtocol) {
        self.publicKey = publicKey
        self.network = network
    }

    /// Creates a new Client item with given public key
    /// - Parameters:
    ///   - country: Omise public key
    public convenience init(publicKey: String) {
        self.init(publicKey: publicKey, network: NetworkService())
    }

    /// Perform Capability API Request
    /// - returns Capability
    public func capability(_ completion: @escaping RequestResultClosure<Capability, Error>) {
        performRequest(api: OmiseAPI.capability) { (result: Result<Capability, Error>) in
            if let capability = try? result.get() {
                OmiseSDK.shared.setCountry(countryCode: capability.countryCode)
            }
            completion(result)
        }
    }
    
    /// Sends Create a Source API request with given Source Payment
    public func createSource(payload: CreateSourcePayload, _ completion: @escaping RequestResultClosure<Source, Error>) {
        performRequest(api: OmiseAPI.createSource(payload: payload), completion: completion)
    }

    /// Send Create a Token API request with given Card Payment
    /// - returns Created Token
    public func createToken(payload: CreateTokenPayload.Card, _ completion: @escaping RequestResultClosure<Token, Error>) {
        let apiPayload = CreateTokenPayload(card: payload)
        performRequest(api: OmiseAPI.createToken(payload: apiPayload), completion: completion)
    }

    /// Perform Token API request with given Token ID
    /// - returns Token
    public func token(tokenID: String, _ completion: @escaping RequestResultClosure<Token, Error>) {
        performRequest(api: OmiseAPI.token(tokenID: tokenID), completion: completion)
    }

    /// Observe Token Charge Status until it changes
    /// Sends API request every `timeInterval` with number of`maxAttempt`attempts.
    /// - returns Latest charge status value
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
