import Foundation


/// Delegate to receive token request events.
public protocol OmiseTokenRequestDelegate {
    /// Delegate method for receiving token data when token request succeeds.
    /// - parameter request: Original `OmiseTokenRequest` that was sent.
    /// - parameter token: `OmiseToken` instance created from supplied card data.
    func tokenRequest(_ request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken)
    
    /// Delegate method for receiving error information when token request failed.
    /// - parameter request: Original `OmiseTokenRequest` that was sent.
    /// - parameter error: The error that occured during the tokenization request.
    func tokenRequest(_ request: OmiseTokenRequest, didFailWithError error: Error)
}

@objc public protocol OMSTokenRequestDelegate {
    func tokenRequest(_ request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken)
    func tokenRequest(_ request: OmiseTokenRequest, didFailWithError error: NSError)
}


/// Contains result of a tokenization request call. `OmiseTokenRequestResult` is an
/// enumeration consisting of two cases:
/// - Succeed: An `OmiseToken` instance can be obtained to create charges.
/// - Fail: An `ErrorType` value can be obtained to find the request failure reason.
public enum OmiseTokenRequestResult {
    /// Tokenization is successful, this case has an associated `OmiseToken` value
    case succeed(token: OmiseToken)
    /// Tokenization, this case has an associated `ErrorType` value.
    case fail(error: Error)
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
    
    func start(with client: OmiseSDKClient, callback: Callback?) -> URLSessionDataTask? {
        let request: URLRequest
        do {
            request = try buildURLRequest(client)
        } catch let err {
            callback?(.fail(error: err))
            return nil
        }
        
        let task = client.session.dataTask(with: request, completionHandler: completeRequest(callback))
        task.resume()
        return task
    }
    
    private func buildURLComponents(_ client: OmiseSDKClient) -> URLComponents {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "card[name]", value: name),
            URLQueryItem(name: "card[number]", value: number),
            URLQueryItem(name: "card[expiration_month]", value: String(expirationMonth)),
            URLQueryItem(name: "card[expiration_year]", value: String(expirationYear)),
            URLQueryItem(name: "card[security_code]", value: securityCode)
        ]
        
        if let city = city {
            queryItems.append(URLQueryItem(name: "card[city]", value: city))
        }
        if let postalCode = postalCode {
            queryItems.append(URLQueryItem(name: "card[postal_code]", value: postalCode))
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "vault.omise.co"
        components.path = "/tokens"
        components.queryItems = queryItems
        
        return components
    }
    
    private func buildURLRequest(_ client: OmiseSDKClient) throws -> URLRequest {
        guard let url = buildURLComponents(client).url else {
            throw OmiseError.unexpected(message: "token request build failure.", underlying: nil)
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(try encodeAuthorizationHeader(client.publicKey), forHTTPHeaderField: "Authorization")
        request.setValue(client.userAgent, forHTTPHeaderField: "User-Agent")
        
        return request as URLRequest
    }
    
    private func encodeAuthorizationHeader(_ publicKey: String) throws -> String {
        let data = publicKey.data(using: String.Encoding.utf8, allowLossyConversion: false)
        guard let base64 = data?.base64EncodedString() else {
            throw OmiseError.unexpected(message: "public key encoding failure.", underlying: nil)
        }
        
        return "Basic \(base64)"
    }
    
    private func completeRequest(_ callback: Callback?) -> (Data?, URLResponse?, Error?) -> () {
        return { (data: Data?, response: URLResponse?, error: Error?) -> () in
            guard let callback = callback else { return } // nobody around to hear the leaf falls
            
            if let error = error {
                return callback(.fail(error: error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = OmiseError.unexpected(message: "no error and no response.", underlying: nil)
                return callback(.fail(error: error))
            }
            
            switch httpResponse.statusCode {
            case 400..<600:
                guard let data = data else {
                    let error = OmiseError.unexpected(message: "error response with no data", underlying: nil)
                    return callback(.fail(error: error))
                }
                
                do {
                    return callback(.fail(error: try OmiseJsonParser.parseError(from: data)))
                } catch let err {
                    let error = OmiseError.unexpected(message: "error response with invalid JSON", underlying: err)
                    return callback(.fail(error: error))
                }
                
            case 200..<300:
                guard let data = data else {
                    let error = OmiseError.unexpected(message: "HTTP 200 but no data", underlying: nil)
                    return callback(.fail(error: error))
                }
                
                do {
                    return callback(.succeed(token: try OmiseJsonParser.parseToken(from: data)))
                } catch let err {
                    let error = OmiseError.unexpected(message: "200 response with invalid JSON", underlying: err)
                    return callback(.fail(error: error))
                }
                
            default:
                let error = OmiseError.unexpected(message: "unrecognized HTTP status code: \(httpResponse.statusCode)", underlying: nil)
                return callback(.fail(error: error))
            }
        }
    }
}
