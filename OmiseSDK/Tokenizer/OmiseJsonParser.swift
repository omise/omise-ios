//
//  OmiseJsonParser.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

import Foundation

public class OmiseJsonParser: NSObject {
    
    public func parseOmiseToken(json: NSString) -> OmiseToken? {
        
        var jsonObject: AnyObject?
        
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
        } catch _ {
            return nil
        }
        
        guard let jsonDict = jsonObject as? NSDictionary else {
            return nil
        }
        
        let object = jsonDict["object"] as? String
        if object == "error" {
            return nil
        }
        
        let token = OmiseToken()
        token.tokenId = jsonDict["id"] as? String
        token.livemode = jsonDict["livemode"] as? Bool
        token.location = jsonDict["location"] as? String
        token.used = jsonDict["used"] as? Bool
        token.created = jsonDict["created"] as? String
        
        guard let cardDict = jsonDict["card"] as? NSDictionary else {
            return nil
        }
        
        guard let card = token.card else {
            return nil
        }
        
        card.cardId = cardDict["id"] as? String
        card.livemode = cardDict["livemode"] as? Bool
        card.location = cardDict["location"] as? String
        card.country = cardDict["country"] as? String
        card.number = cardDict["number"] as? String
        card.city = cardDict["city"] as? String
        card.postalCode = cardDict["postal_code"] as? String
        card.financing = cardDict["financing"] as? String
        card.lastDigits = cardDict["last_digits"] as? String
        card.brand = cardDict["brand"] as? String
        card.expirationMonth = cardDict["expiration_month"] as? Int
        card.expirationYear = cardDict["expiration_year"] as? Int
        card.fingerprint = cardDict["fingerprint"] as? String
        card.name = cardDict["name"] as? String
        card.securityCodeCheck = cardDict["security_code_check"] as? Bool
        card.created = cardDict.objectForKey("created") as? String
        
        return token
    }
    
    public func parseOmiseError(json: NSString) -> OmiseError? {
        
        var jsonObject: AnyObject?
        
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
        } catch _ {
            return nil
        }
        
        guard let jsonDict = jsonObject as? NSDictionary else {
            return nil
        }
        
        let object = jsonDict["object"] as? String
        if object != "error" {
            return nil
        }
        
        let error = OmiseError()
        error.location = jsonDict["location"] as? String
        error.code = jsonDict["code"] as? String
        error.message = jsonDict["message"] as? String
        
        return error
    }
}
