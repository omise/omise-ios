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
    
    var data: NSMutableData?
    var requestObject: OmiseRequestObject?
    var delegate: OmiseTokenizerDelegate?
    
    // MARK: - Create a Token
    func requestToken(requestObject: OmiseRequestObject?) {
        
        let URL = NSURL(string: "https://vault.omise.co/tokens")!
        let OMISE_IOS_VERSION = "2.0.0"
        let req = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        req.HTTPMethod = "POST"
        
        self.requestObject = requestObject
        
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
        
        let body = "card[name]=\(card.name!)&card[city]=\(city)&card[postal_code]=\(postalCode)&card[number]=\(card.number!)&card[expiration_month]=\(card.expirationMonth!)&card[expiration_year]=\(card.expirationYear!)&card[security_code]=\(card.securityCode!)"
        
        req.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let loginString = "\(requestObject.publicKey!):"
        let plainData = loginString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let base64LoginData = "Basic \(base64String!)"
        let userAgentData = "OmiseIOSSwift/\(OMISE_IOS_VERSION)"
        req.setValue(base64LoginData, forHTTPHeaderField: "Authorization")
        req.setValue(userAgentData, forHTTPHeaderField: "User-Agent")
        
        let reqSession = NSURLSession.sharedSession()
        let reqTask = reqSession.dataTaskWithRequest(req) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
        }
        reqTask.resume()
    
    }
    
    
}
