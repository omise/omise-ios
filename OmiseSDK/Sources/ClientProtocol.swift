import Foundation

/// Network Client Protocol to communicate with Omise APIs
public protocol ClientProtocol {
    typealias ResponseClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void
    
    /// Latest capability loaded with `capability()`
    var latestLoadedCapability: Capability? { get }

    /// Performs a Capability API Request
    /// - parameter completion: Returns `Capability` object on success and `Error` on request failed
    func capability(_ completion: @escaping ResponseClosure<Capability, Error>)

    /// Sends `Create a Source` API request with given Payment Payload
    /// - parameter payload: Information required to perform Create a Source API request
    /// - parameter completion: Returns `Source` object on success and `Error` on request failed
    func createSource(payload: CreateSourcePayload, _ completion: @escaping ResponseClosure<Source, Error>)

    /// Sends `Create a Token` API request with given Card Payment
    /// - parameter payload: Information required to perform Create a Token API request
    /// - parameter completion: Returns `Token`object  on success and `Error` on request failed
    func createToken(payload: CreateTokenPayload, _ completion: @escaping ResponseClosure<Token, Error>)

    /// Sends `Create a Token` API request with return ApplePay's PKPayment  token
    /// - parameter applePayToken: Information required to perform Create a Token API request with ApplePay token Payload
    /// - parameter completion: Returns `Token`object  on success and `Error` on request failed
    func createToken(applePayToken: CreateTokenApplePayPayload, _ completion: @escaping ResponseClosure<Token, Error>)
    
    /// Requests a `Token` from API with given Token ID
    /// - parameter tokenID: Token identifier
    /// - parameter completion: Returns `Token`object  on success and `Error` on request failed
    func token(tokenID: String, _ completion: @escaping ResponseClosure<Token, Error>)

    /// Observes `Token Charge Status` until it changes or max attempts is reached
    /// - parameter tokenID: Token identifier
    /// - parameter completion: Returns `Token.ChargeStatus`object with token charge status value  on success and `Error` on request failed
    func observeChargeStatus(tokenID: String, _ completion: @escaping ResponseClosure<Token.ChargeStatus, Error>)
}
