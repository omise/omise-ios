//
//  Omise.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

import Foundation

public protocol OmiseTokenizerDelegate {
    func OmiseRequestTokenOnSucceeded(token: OmiseToken?)
    func OmiseRequestTokenOnFailed(error: NSError?)
}

public class Omise: NSObject {
    
    public var delegate: OmiseTokenizerDelegate?
    
    // MARK: - Create a Token
    public func requestToken(requestObject: OmiseRequestObject?) {
        
        let URL = NSURL(string: "https://vault.omise.co/tokens")!
        let OMISE_IOS_VERSION = "2.1.0"
        let request = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.HTTPMethod = "POST"
                
        guard let requestObject = requestObject else {
            return
        }
        
        guard let card = requestObject.card else {
            return
        }
        
        var city = ""
        var postalCode = ""
        
        if let userCity = card.city {
            city = userCity
        }
        
        if let userPostalCode = card.postalCode {
            postalCode = userPostalCode
        }
        
        guard let name = card.name, let number = card.number, let expirationMonth = card.expirationMonth, let expirationYear = card.expirationYear, let securityCode = card.securityCode else {
            print("Please insert card information")
            return
        }
        
        let body = "card[name]=\(name)&card[city]=\(city)&card[postal_code]=\(postalCode)&card[number]=\(number)&card[expiration_month]=\(expirationMonth)&card[expiration_year]=\(expirationYear)&card[security_code]=\(securityCode)"
        
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let loginString = "\(requestObject.publicKey!):"
        let plainData = loginString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let base64LoginData = "Basic \(base64String!)"
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
        
    }
}
