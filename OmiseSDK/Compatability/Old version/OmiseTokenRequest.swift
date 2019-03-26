import Foundation


@available(*, deprecated, message: "Use the new `Token` data type instead. This class will be removed in the future released", renamed: "Token")
public typealias OmiseToken = __OmiseToken


/// Delegate to receive token request events.
@available(*, deprecated, message: "Use the completion handler pattern in the `Client` instead. This protocol will be removed in the future released")
public protocol OmiseTokenRequestDelegate {
    /// Delegate method for receiving token data when token request succeeds.
    /// - parameter request: Original `OmiseTokenRequest` that was sent.
    /// - parameter token: `OmiseToken` instance created from supplied card data.
    func tokenRequest(_ request: OmiseTokenRequest, didSucceedWithToken token: __OmiseToken)
    
    /// Delegate method for receiving error information when token request failed.
    /// - parameter request: Original `OmiseTokenRequest` that was sent.
    /// - parameter error: The error that occured during the tokenization request.
    func tokenRequest(_ request: OmiseTokenRequest, didFailWithError error: Error)
}

/// Contains result of a tokenization request call. `OmiseTokenRequestResult` is an
/// enumeration consisting of two cases:
/// - Succeed: An `OmiseToken` instance can be obtained to create charges.
/// - Fail: An `ErrorType` value can be obtained to find the request failure reason.
@available(*, deprecated, message: "Use the new `RequestResult` type. This enum will be removed in the future released", renamed: "RequestResult")
public enum OmiseTokenRequestResult {
    /// Tokenization is successful, this case has an associated `OmiseToken` value
    case succeed(token: __OmiseToken)
    /// Tokenization, this case has an associated `ErrorType` value.
    case fail(error: Error)
}


/**
 Encapsulates information required to perform tokenization requests.
 - seealso: [Tokens API](https://www.omise.co/tokens-api)
 */
@available(*, deprecated, message: "Use the new `Request<Token>` type. This class will be removed in the future released", renamed: "Request")
public class OmiseTokenRequest: NSObject {
    
    let request: Request<Token>
  
    /// Tokenization request callback function type.
    public typealias Callback = (OmiseTokenRequestResult) -> ()
    
    /// Card holder's full name.
    @objc public var name: String {
        return request.parameter.name
    }
    /// Card number.
    @objc public var number: String {
        return request.parameter.number
    }
    /// Card expiration month (1-12)
    @objc public var expirationMonth: Int {
        return request.parameter.expirationMonth
    }
    /// Card expiration year (Gregorian)
    @objc public var expirationYear: Int {
        return request.parameter.expirationYear
    }
    /// Security code (CVV, CVC, etc) printed on the back of the card.
    @objc public var securityCode: String {
        return request.parameter.securityCode
    }
    /// Issuing city.
    @objc public var city: String? {
        return request.parameter.city
    }
    /// Postal code.
    @objc public var postalCode: String? {
        return request.parameter.postalCode
    }
    
    /// Initializes new token request.
    @objc public init(name: String, number: String, expirationMonth: Int, expirationYear: Int,
                      securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.request = Request<Token>(
            name: name, number: number,
            expirationMonth: expirationMonth, expirationYear: expirationYear,
            securityCode: securityCode, city: city, postalCode: postalCode
        )
    }
    
    func start(with client: OmiseSDKClient, callback: Callback?) -> URLSessionDataTask? {
        return client.client.send(self.request, completionHandler: OmiseTokenRequest.tokenRequestCallback(from: callback)).dataTask
    }
    
    static func tokenRequestCallback(from callback: OmiseTokenRequest.Callback?) -> Request<Token>.Callback {
        return { (result) in
            let tokenRequestResult: OmiseTokenRequestResult
            switch result {
            case .success(let token):
                tokenRequestResult = .succeed(token: __OmiseToken(token: token))
            case .failure(let error):
                tokenRequestResult = .fail(error: error)
            }
            callback?(tokenRequestResult)
        }
    }
}
