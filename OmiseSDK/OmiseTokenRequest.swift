import Foundation


/// Delegate to receive token request events.
public protocol OmiseTokenRequestDelegate {
    /// Delegate method for receiving token data when token request succeeds.
    /// - parameter request: Original `OmiseTokenRequest` that was sent.
    /// - parameter token: `OmiseToken` instance created from supplied card data.
    func tokenRequest(request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken)
    
    /// Delegate method for receiving error information when token request failed.
    /// - parameter request: Original `OmiseTokenRequest` that was sent.
    /// - parameter error: The error that occured during the tokenization request.
    func tokenRequest(request: OmiseTokenRequest, didFailWithError error: ErrorType)
}

@objc public protocol OMSTokenRequestDelegate {
    func tokenRequest(request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken)
    func tokenRequest(request: OmiseTokenRequest, didFailWithError error: NSError)
}


/// Contains result of a tokenization request call. `OmiseTokenRequestResult` is an
/// enumeration consisting of two cases:
/// - Succeed: An `OmiseToken` instance can be obtained to create charges.
/// - Fail: An `ErrorType` value can be obtained to find the request failure reason.
public enum OmiseTokenRequestResult {
    /// Tokenization is successful, this case has an associated `OmiseToken` value
    case Succeed(token: OmiseToken)
    /// Tokenization, this case has an associated `ErrorType` value.
    case Fail(error: ErrorType)
}


/**
 Encapsulates information required to perform tokenization requests.
 - seealso: [Tokens API](https://www.omise.co/tokens-api)
 */
@objc(OMSTokenRequest) public class OmiseTokenRequest: NSObject {
  
    /// Tokenization request callback function type.
    public typealias Callback = (OmiseTokenRequestResult) -> ()
    
    /// Card holder's full name.
    @objc public let name: String
    /// Card number.
    @objc public let number: String
    /// Card expiration month (1-12)
    @objc public let expirationMonth: Int
    /// Card expiration year (Gregorian)
    @objc public let expirationYear: Int
    /// Security code (CVV, CVC, etc) printed on the back of the card.
    @objc public let securityCode: String
    /// Issuing city.
    @objc public let city: String?
    /// Postal code.
    @objc public let postalCode: String?
    
    /// Initializes new token request.
    @objc public init(name: String, number: String, expirationMonth: Int, expirationYear: Int,
                      securityCode: String, city: String? = nil, postalCode: String? = nil) {
        self.name = name
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.city = city
        self.postalCode = postalCode
    }
    
    func startWith(client: OmiseSDKClient, callback: Callback?) -> NSURLSessionDataTask? {
        let request: NSURLRequest
        do {
            request = try buildURLRequest(client)
        } catch let err {
            callback?(.Fail(error: err))
            return nil
        }
        
        let task = client.session.dataTaskWithRequest(request, completionHandler: completeRequest(callback))
        task.resume()
        return task
    }
    
    private func buildURLComponents(client: OmiseSDKClient) -> NSURLComponents {
        var queryItems: [NSURLQueryItem] = [
            NSURLQueryItem(name: "card[name]", value: name),
            NSURLQueryItem(name: "card[number]", value: number),
            NSURLQueryItem(name: "card[expiration_month]", value: String(expirationMonth)),
            NSURLQueryItem(name: "card[expiration_year]", value: String(expirationYear)),
            NSURLQueryItem(name: "card[security_code]", value: securityCode)
        ]
        
        if let city = city {
            queryItems.append(NSURLQueryItem(name: "card[city]", value: city))
        }
        if let postalCode = postalCode {
            queryItems.append(NSURLQueryItem(name: "card[postal_code]", value: postalCode))
        }
        
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "vault.omise.co"
        components.path = "/tokens"
        components.queryItems = queryItems
        
        return components
    }
    
    private func buildURLRequest(client: OmiseSDKClient) throws -> NSURLRequest {
        guard let url = buildURLComponents(client).URL else {
            throw OmiseError.Unexpected(message: "token request build failure.", underlying: nil)
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue(try encodeAuthorizationHeader(client.publicKey), forHTTPHeaderField: "Authorization")
        request.setValue(client.userAgent, forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    private func encodeAuthorizationHeader(publicKey: String) throws -> String {
        let data = publicKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        guard let base64 = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) else {
            throw OmiseError.Unexpected(message: "public key encoding failure.", underlying: nil)
        }
        
        return "Basic \(base64)"
    }
    
    private func completeRequest(callback: Callback?) -> (NSData?, NSURLResponse?, NSError?) -> () {
        return { (data: NSData?, response: NSURLResponse?, error: NSError?) -> () in
            guard let callback = callback else { return } // nobody around to hear the leaf falls
            
            if let error = error {
                return callback(.Fail(error: error))
            }
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                let error = OmiseError.Unexpected(message: "no error and no response.", underlying: nil)
                return callback(.Fail(error: error))
            }
            
            switch httpResponse.statusCode {
            case 400..<600:
                guard let data = data else {
                    let error = OmiseError.Unexpected(message: "error response with no data", underlying: nil)
                    return callback(.Fail(error: error))
                }
                
                do {
                    return callback(.Fail(error: try OmiseJsonParser.parseError(data)))
                } catch let err {
                    let error = OmiseError.Unexpected(message: "error response with invalid JSON", underlying: err)
                    return callback(.Fail(error: error))
                }
                
            case 200..<300:
                guard let data = data else {
                    let error = OmiseError.Unexpected(message: "HTTP 200 but no data", underlying: nil)
                    return callback(.Fail(error: error))
                }
                
                do {
                    return callback(.Succeed(token: try OmiseJsonParser.parseToken(data)))
                } catch let err {
                    let error = OmiseError.Unexpected(message: "200 response with invalid JSON", underlying: err)
                    return callback(.Fail(error: error))
                }
                
            default:
                let error = OmiseError.Unexpected(message: "unrecognized HTTP status code: \(httpResponse.statusCode)", underlying: nil)
                return callback(.Fail(error: error))
            }
        }
    }
}
