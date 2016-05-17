import Foundation

public protocol OmiseTokenizerDelegate {
    func OmiseRequestTokenOnSucceeded(token: OmiseToken?)
    func OmiseRequestTokenOnFailed(error: NSError?)
}

public class Omise: NSObject {
    let OMISE_IOS_VERSION = "2.1.0"
    public var delegate: OmiseTokenizerDelegate?
    public let publicKey: String
    
    // MARK: - Initial
    public init(publicKey: String) {
        self.publicKey = publicKey
    }
    
    // MARK: - Create a Token
    public func requestToken(requestObject: OmiseRequestObject?) {
        guard let requestObject = requestObject else {
            return
        }
        
        guard let URL = createURLComponent(requestObject) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.HTTPMethod = "POST"
        
        let loginString = (self.publicKey ?? "")
        let plainData = loginString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        guard let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) else {
            print("Can't encoding plainData to base64String")
            return
        }
        
        let base64LoginData = "Basic \(base64String)"
        let userAgentData = "OmiseIOSSwift/\(OMISE_IOS_VERSION)"
        request.setValue(base64LoginData, forHTTPHeaderField: "Authorization")
        request.setValue(userAgentData, forHTTPHeaderField: "User-Agent")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: didComplete)
        task.resume()
    
    }
    
    private func didComplete(data: NSData?, response: NSURLResponse?, error: NSError?) {
        
        guard let delegate = delegate else {
            print("Please set delegate before request token")
            return
        }
        
        if let error = error {
            return delegate.OmiseRequestTokenOnFailed(error)
        }

        guard let httpResponse = response as? NSHTTPURLResponse else {
            let error = OmiseError.UnexpectedError("No error and no response")
            return delegate.OmiseRequestTokenOnFailed(error)
        }
        
        switch httpResponse.statusCode {
        case 400..<600:
            guard let data = data else {
                let error = OmiseError.UnexpectedError("Error response with no data")
                return delegate.OmiseRequestTokenOnFailed(error)
            }
            
            guard let errorResponse = OmiseJsonParser().parseOmiseError(data) else {
                let error = OmiseError.UnexpectedError("Error response deserialization failure")
                return delegate.OmiseRequestTokenOnFailed(error)
            }
            
            let error = OmiseError.ErrorFromResponse(errorResponse)
            return delegate.OmiseRequestTokenOnFailed(error)
            
        case 200..<300:
            guard let data = data else {
                let error = OmiseError.UnexpectedError("HTTP 200 but no data")
                return delegate.OmiseRequestTokenOnFailed(error)
            }
            
            guard let token = OmiseJsonParser().parseOmiseToken(data) else {
                let error = OmiseError.UnexpectedError("Error response deserialization failure")
                return delegate.OmiseRequestTokenOnFailed(error)
            }
            
            return delegate.OmiseRequestTokenOnSucceeded(token)
        default:
            print("unrecognized HTTP status code: \(httpResponse.statusCode)")
        }

    }
    
    // MARK: - Carete URLComponents by NSURLQueryItem
    private func createURLComponent(requestObject: OmiseRequestObject) -> NSURL? {
        guard let card = requestObject.card else {
            print("Card information can't be null")
            return nil
        }
        
        guard let name = card.name, let number = card.number else {
            print("Card name or number can't be null")
            return nil
        }
        
        guard let expirationMonth = card.expirationMonth, let expirationYear = card.expirationYear else {
            print("Expiration date can't be null")
            return nil
        }
        
        guard let securityCode = card.securityCode else {
            print("Security code can't be null")
            return nil
        }
        
        let nameQuery = NSURLQueryItem(name: "card[name]", value: name)
        let numberQuery = NSURLQueryItem(name: "card[number]", value: number)
        let expirationMonthQuery = NSURLQueryItem(name: "card[expiration_month]", value: String(expirationMonth))
        let expirationYearQuery = NSURLQueryItem(name: "card[expiration_year]", value: String(expirationYear))
        let securityCodeQuery = NSURLQueryItem(name: "card[security_code]", value: String(securityCode))
        let cityQuery = NSURLQueryItem(name: "card[city]", value: (card.city ?? ""))
        let postalCodeQuery = NSURLQueryItem(name: "card[postal_code]", value: (card.postalCode ?? ""))
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "vault.omise.co"
        urlComponents.path = "/tokens"
        urlComponents.queryItems = [nameQuery, numberQuery, expirationMonthQuery, expirationYearQuery, securityCodeQuery, cityQuery, postalCodeQuery]
        
        return urlComponents.URL
    }
}
