import Foundation



public protocol OmiseTokenRequestDelegate {
    /// A delegate method that will be called when the card tokenization is successful.
    /// - parameter request: A card tokenization request.
    /// - parameter token: The token that generated from Omise server.
    func tokenRequest(request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken)
    /// A delegate method that will be called when the card tokenization is failed.
    /// - parameter request: A card tokenization request.
    /// - parameter error: The error that occurred during the tokenization.
    func tokenRequest(request: OmiseTokenRequest, didFailWithError error: ErrorType)
}

@objc public protocol OMSTokenRequestDelegate {
    func tokenRequest(request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken)
    func tokenRequest(request: OmiseTokenRequest, didFailWithError error: NSError)
}


/// A card tokenization result data type. This data type consists of 2 cases
/// - Succeed
/// - Fail
public enum OmiseTokenRequestResult {
    /// Represents that the tokenization is succeed, this case has an associative token value
    case Succeed(token: OmiseToken)
    /// Represents that the tokenization is failed, this case has an associative error
    case Fail(error: ErrorType)
}


/**
 A card tokenization request object contains the information that required to perform tokenization
 - seealso: [The Omise Token API documentation](https://www.omise.co/tokens-api)
 */
@objc(OMSTokenRequest) public class OmiseTokenRequest: NSObject {
  
    /// A completion callback closure type which has a `OmiseTokenRequestResult` as a parameter.
    public typealias Callback = (OmiseTokenRequestResult) -> ()
    
    /// A name of the card holder
    @objc public let name: String
    /// A card number for tokenization
    @objc public let number: String
    /// The card expiration month (1-12)
    @objc public let expirationMonth: Int
    /// The card expiration year (in Gregorian)
    @objc public let expirationYear: Int
    /// The security code (CVV, CVC, etc) printed on the back of the card.
    @objc public let securityCode: String
    /// The city where the card is issued.
    @objc public let city: String?
    /// The postal code from the city where the card was issued
    @objc public let postalCode: String?
    
    /// An initializer to create a tokenization request.
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
