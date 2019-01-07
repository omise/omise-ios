import Foundation


/// Delegate to receive token request events.
@objc public protocol OMSTokenRequestDelegate {
    func tokenRequest(_ request: __OMSTokenRequest, didSucceedWithToken token: __OmiseToken)
    func tokenRequest(_ request: __OMSTokenRequest, didFailWithError error: NSError)
}


/// Request object for describing a request to create a new token with the creating parameters
@objc(OMSTokenRequest) public class __OMSTokenRequest: NSObject {
    
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
    
    let request: Request<Token>
    
    /// Initializes new token request.
    @objc public init(name: String, number: String, expirationMonth: Int, expirationYear: Int,
                      securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.request = Request<Token>(
            name: name, number: number,
            expirationMonth: expirationMonth, expirationYear: expirationYear,
            securityCode: securityCode, city: city, postalCode: postalCode
        )
    }
}

