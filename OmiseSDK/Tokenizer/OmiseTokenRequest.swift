import Foundation

public class OmiseTokenRequest: NSObject {
    public var name: String
    public var number: String
    public var expirationMonth: Int
    public var expirationYear: Int
    public var securityCode: String
    public var city: String?
    public var postalCode: String?
    
    public typealias Callback = (OmiseToken?, ErrorType?) -> ()
    
    public init(name: String, number: String, expirationMonth: Int, expirationYear: Int, securityCode: String, city: String?, postalCode: String?) {
        self.name = name
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.city = city
        self.postalCode = postalCode
    }
    
    func startWith(client: Omise, callback: Callback?) {
        guard let request = createURLRequest(client) else {
            callback?(nil, OmiseError.Unexpected("request initialization error."))
            return
        }
        
        let dataTask = client.session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard let callback = callback else {
                OmiseWarning.SDKWarn("Callback is null")
                return
            }
            
            if let error = error {
                return callback(nil, error)
            }
            
            let reponse = self.buildReturnReponse(data, response: response)
            callback(reponse.token, reponse.error)
        }
        dataTask.resume()
    }
    
    // MARK: - Carete URLComponents by NSURLQueryItem
    private func createURLComponent(client: Omise) -> NSURLComponents? {
        var queryItems: [NSURLQueryItem] = []
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "vault.omise.co"
        urlComponents.path = "/tokens"
        
        let nameQuery = NSURLQueryItem(name: "card[name]", value: name)
        let numberQuery = NSURLQueryItem(name: "card[number]", value: number)
        let expirationMonthQuery = NSURLQueryItem(name: "card[expiration_month]", value: String(expirationMonth))
        let expirationYearQuery = NSURLQueryItem(name: "card[expiration_year]", value: String(expirationYear))
        let securityCodeQuery = NSURLQueryItem(name: "card[security_code]", value: securityCode)
        
        if let city = city {
            let cityQuery = NSURLQueryItem(name: "card[city]", value: city)
            queryItems.append(cityQuery)
        }
        
        if let postalCode = postalCode {
            let postalCodeQuery = NSURLQueryItem(name: "card[postal_code]", value: postalCode)
            queryItems.append(postalCodeQuery)
        }
        
        queryItems.append(nameQuery)
        queryItems.append(numberQuery)
        queryItems.append(expirationMonthQuery)
        queryItems.append(expirationYearQuery)
        queryItems.append(securityCodeQuery)
        
        urlComponents.queryItems = queryItems
        
        return urlComponents
    }
    
    private func createURLRequest(client: Omise) -> NSURLRequest? {
        guard let url = createURLComponent(client)?.URL else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 15)
        request.HTTPMethod = "POST"
        
        let plainData = client.publicKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        guard let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) else {
            OmiseWarning.SDKWarn("Can't encoding plainData to base64String")
            return nil
        }
        
        let base64LoginData = "Basic \(base64String)"
        let userAgentData = "OmiseIOSSDK/\(OMISE_SDK_VERSION)/Swift/\(SWIFT_VERSION)/iOS/\(IOS_VERSION)/Apple/\(DEVICE)"
        request.setValue(base64LoginData, forHTTPHeaderField: "Authorization")
        request.setValue(userAgentData, forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    private func buildReturnReponse(data: NSData?, response: NSURLResponse?) -> (token: OmiseToken?, error: NSError?) {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            let error = OmiseError.Unexpected("No error and no response")
            return (nil, error)
        }
        
        switch httpResponse.statusCode {
        case 400..<600:
            guard let data = data else {
                let error = OmiseError.Unexpected("Error response with no data")
                return (nil, error)
            }
            
            guard let omiseError = try? OmiseJsonParser().parseOmiseError(data) else {
                let error = OmiseError.Unexpected("Error response deserialization failure")
                return (nil, error)
            }
            
            let error = omiseError.nsError
            return (nil, error)
            
        case 200..<300:
            guard let data = data else {
                let error = OmiseError.Unexpected("HTTP 200 but no data")
                return (nil, error)
            }
            
            guard let token = try? OmiseJsonParser().parseOmiseToken(data) else {
                let error = OmiseError.Unexpected("Error response deserialization failure")
                return (nil, error)
            }
            
            return (token, nil)
            
        default:
            let error = OmiseError.Unexpected("Error unrecognized HTTP status code: \(httpResponse.statusCode)")
            return (nil,error)
        }
    }

}