import Foundation
import os

/// Network Client to communicate with Omise APIs
public class Client {
    public typealias RequestResultClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void

    private enum Const {
        static let observingAttemptsCount = 10
        static let observingTimeInterval = 3
    }

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
        apiRequest(api: OmiseAPI.capability) { (result: Result<Capability, Error>) in
            if let capability = try? result.get() {
                OmiseSDK.shared.setCurrentCountry(countryCode: capability.countryCode)
            }
            completion(result)
        }
    }

    /// Observe Token Charge Status until it changes
    /// Sends API request every `timeInterval` with number of`maxAttempt`attempts.
    /// - returns Latest charge status value
    public func observeChargeStatusUntilChange(tokenID: String, _ completion: @escaping RequestResultClosure<Token.ChargeStatus, Error>) {
        observeChargeStatusUntilChange(
            tokenID: tokenID,
            timeInterval: Self.Const.observingTimeInterval,
            attemp: 0,
            maxAttempt: Self.Const.observingAttemptsCount,
            completion
        )
    }

    /// Send Create a Token API request with given Card Payment
    /// - returns Created Token
    public func createToken(payload: CardPaymentPayload, _ completion: @escaping RequestResultClosure<Token, Error>) {
        apiRequest(api: OmiseAPI.createToken(payload: payload), completion: completion)
    }

    /// Sends Create a Source API request with given Source Payment
    public func createSource(payload: SourcePaymentPayload, _ completion: @escaping RequestResultClosure<Source, Error>) {
        apiRequest(api: OmiseAPI.createSource(payload: payload), completion: completion)
    }
}
