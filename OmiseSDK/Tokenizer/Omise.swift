import Foundation

public protocol OmiseTokenizerDelegate {
    func OmiseRequestTokenOnSucceeded(token: OmiseToken)
    func OmiseRequestTokenOnFailed(error: NSError)
}

public class Omise: NSObject {
    let OMISE_IOS_VERSION = "2.1.0"
    let SWIFT_VERSION = "2.2"
    let IOS_VERSION = NSProcessInfo.processInfo().operatingSystemVersionString
    let DEVICE = UIDevice.currentDevice().model
    
    public var delegate: OmiseTokenizerDelegate?
    public let publicKey: String
    
    public typealias Callback = (OmiseToken?, NSError?) -> ()
    private var callback: Callback? = nil
    
    // MARK: - Initial
    public init(publicKey: String) {
        self.publicKey = publicKey
    }
    
    // MARK: - Create a Token
    public func requestToken(requestObject: OmiseTokenRequest, tokenizerDelegate: OmiseTokenizerDelegate) {
        guard let request = createURLRequest(requestObject) else {
            let error = OmiseError.UnexpectedError("Error can't create url request")
            return tokenizerDelegate.OmiseRequestTokenOnFailed(error)
        }
        
        self.delegate = tokenizerDelegate
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: didCompleteWithDelegate)
        task.resume()
        
    }
    
    public func requestToken(requestObject: OmiseTokenRequest, onCompletion completion: ((OmiseToken?, NSError?) -> Void)) {
        
        self.callback = completion
        
        guard let urlRequest = createURLRequest(requestObject) else {
            let error = OmiseError.UnexpectedError("Error can't create url request")
            return completion(nil, error)
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: didCompleteWithCallBack)
        task.resume()
    }
    
    private func didCompleteWithDelegate(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let delegate = delegate else {
            OmiseWarning.SDKWarning("Please set delegate before request token")
            return
        }
        
        if let error = error {
            return delegate.OmiseRequestTokenOnFailed(error)
        }
        
        let response = buildReturnReponse(data, response: response)
        guard let token = response.token else {
            if let error = response.error {
                return delegate.OmiseRequestTokenOnFailed(error)
            }
            
            let error = OmiseError.UnexpectedError("Unexpected error")
            return delegate.OmiseRequestTokenOnFailed(error)
        }
        
        delegate.OmiseRequestTokenOnSucceeded(token)
    }
    
    private func didCompleteWithCallBack(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let callback = callback else {
            OmiseWarning.SDKWarning("Callback is null")
            return
        }
        
        if let error = error {
            return callback(nil, error)
        }
        
        let reponse = buildReturnReponse(data, response: response)
        callback(reponse.token, reponse.error)
        
    }
    
    private func buildReturnReponse(data: NSData?, response: NSURLResponse?) -> (token: OmiseToken?, error: NSError?) {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            let error = OmiseError.UnexpectedError("No error and no response")
            return (nil, error)
        }
        
        switch httpResponse.statusCode {
        case 400..<600:
            guard let data = data else {
                let error = OmiseError.UnexpectedError("Error response with no data")
                return (nil, error)
            }
            
            do {
                guard let omiseError = try OmiseJsonParser().parseOmiseError(data) else {
                    let error = OmiseError.UnexpectedError("Error response deserialization failure")
                    return (nil, error)
                }
                
                let error = omiseError.nsError
                return (nil, error)
                
            } catch (let error as NSError) {
                return (nil, error)
            }
            
        case 200..<300:
            guard let data = data else {
                let error = OmiseError.UnexpectedError("HTTP 200 but no data")
                return (nil, error)
            }
            
            guard let token = OmiseJsonParser().parseOmiseToken(data) else {
                let error = OmiseError.UnexpectedError("Error response deserialization failure")
                return (nil, error)
            }
            
            return (token, nil)
            
        default:
            let error = OmiseError.UnexpectedError("Error unrecognized HTTP status code: \(httpResponse.statusCode)")
            return (nil,error)
        }
    }
    
    // MARK: - Carete URLComponents by NSURLQueryItem
    private func createURLComponent(requestObject: OmiseTokenRequest) -> NSURL? {
        
        var queryItems: [NSURLQueryItem] = []
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "vault.omise.co"
        urlComponents.path = "/tokens"
        
        let nameQuery = NSURLQueryItem(name: "card[name]", value: requestObject.name)
        let numberQuery = NSURLQueryItem(name: "card[number]", value: requestObject.number)
        let expirationMonthQuery = NSURLQueryItem(name: "card[expiration_month]", value: String(requestObject.expirationMonth))
        let expirationYearQuery = NSURLQueryItem(name: "card[expiration_year]", value: String(requestObject.expirationYear))
        let securityCodeQuery = NSURLQueryItem(name: "card[security_code]", value: requestObject.securityCode)
        
        if let city = requestObject.city {
            let cityQuery = NSURLQueryItem(name: "card[city]", value: city)
            queryItems.append(cityQuery)
        }
        
        if let postalCode = requestObject.postalCode {
            let postalCodeQuery = NSURLQueryItem(name: "card[postal_code]", value: postalCode)
            queryItems.append(postalCodeQuery)
        }
        
        queryItems.append(nameQuery)
        queryItems.append(numberQuery)
        queryItems.append(expirationMonthQuery)
        queryItems.append(expirationYearQuery)
        queryItems.append(securityCodeQuery)
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.URL
    }
    
    private func createURLRequest(requestObject: OmiseTokenRequest) -> NSMutableURLRequest? {
        guard let URL = createURLComponent(requestObject) else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: URL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 15)
        request.HTTPMethod = "POST"
        
        let plainData = self.publicKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        guard let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) else {
            OmiseWarning.SDKWarning("Can't encoding plainData to base64String")
            return nil
        }
        
        let base64LoginData = "Basic \(base64String)"
        let userAgentData = "OmiseIOSSDK/\(OMISE_IOS_VERSION)/Swift/\(SWIFT_VERSION)/iOS/\(IOS_VERSION)/Apple/\(DEVICE)"
        request.setValue(base64LoginData, forHTTPHeaderField: "Authorization")
        request.setValue(userAgentData, forHTTPHeaderField: "User-Agent")
        
        return request
    }
}