import Foundation

public protocol OmiseTokenizerDelegate {
    func OmiseRequestTokenOnSucceeded(token: OmiseToken?)
    func OmiseRequestTokenOnFailed(error: NSError?)
}

public class Omise: NSObject {
    let OMISE_IOS_VERSION = "2.1.0"
    public var delegate: OmiseTokenizerDelegate?
    
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
        
        let loginString = (requestObject.publicKey ?? "")
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
        let task = session.dataTaskWithRequest(request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if error != nil {
                self.requestTokenOnFail(error!)
            } else {
                self.requestTokenOnSucceeded(data)
            }
        }
        
        task.resume()
    
    }
    
    private func requestTokenOnSucceeded(data: NSData?) {
        guard let data = data else {
            self.handleErrorDataIsEmpty()
            return
        }
        
        guard let result = NSString(data: data, encoding:
            NSASCIIStringEncoding) else {
            self.handleErrorDataEncoding()
            return
        }
        
        let jsonParser = OmiseJsonParser()
        guard let token = jsonParser.parseOmiseToken(result) else {
            
            if let omiseError = jsonParser.parseOmiseError(result) {
                
                let error = OmiseError.errorFromResponse(omiseError)
                
                guard let delegate = delegate else { return }
                delegate.OmiseRequestTokenOnFailed(error)
            }
            return
        }
        
        guard let delegate = delegate else { return }
        delegate.OmiseRequestTokenOnSucceeded(token)
    }
    
    private func requestTokenOnFail(error: NSError) {
        let requestError = NSError(domain: OmiseErrorDomain, code: error.code, userInfo: error.userInfo)
        
        guard let delegate = delegate else {
            return
        }
        
        delegate.OmiseRequestTokenOnFailed(requestError)
    }
    
    private func handleErrorDataIsEmpty() {
        guard let delegate = delegate else {
            return
        }
        
        let userInfo: [NSObject: AnyObject] =
            [ NSLocalizedDescriptionKey:  NSLocalizedString("Response data is null", value: "Response data is null", comment: "") ]
        let dataError = NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.UnexpectedError.rawValue, userInfo: userInfo)
        delegate.OmiseRequestTokenOnFailed(dataError)
    }
    
    private func handleErrorDataEncoding() {
        guard let delegate = delegate else {
            return
        }
        
        let userInfo: [NSObject: AnyObject] =
            [ NSLocalizedDescriptionKey:  NSLocalizedString("Response data can't encoding", value: "Response data can't encoding", comment: "") ]
        let dataError = NSError(domain: OmiseErrorDomain, code: OmiseErrorCode.UnexpectedError.rawValue, userInfo: userInfo)
        delegate.OmiseRequestTokenOnFailed(dataError)
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
