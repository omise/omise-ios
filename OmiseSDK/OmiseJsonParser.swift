import Foundation

public final class OmiseJsonParser: NSObject {
    public static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
    public static func parseToken(data: NSData) throws -> OmiseToken {
        let dict = try parseJSON(data)
        guard dict["object"] as? String == "token" else {
            throw OmiseError.Unexpected(message: "Bad JSON response.", underlying: nil)
        }
        guard let cardDict = dict["card"] as? NSDictionary else {
            throw OmiseError.Unexpected(message: "Bad JSON response.", underlying: nil)
        }
        
        let card = OmiseCard()
        card.cardId = cardDict["id"] as? String
        card.livemode = cardDict["livemode"] as? Bool
        card.location = cardDict["location"] as? String
        card.country = cardDict["country"] as? String
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
        card.created = parseJSONDate(cardDict["created"] as? String)
        
        let token = OmiseToken()
        token.tokenId = dict["id"] as? String
        token.livemode = dict["livemode"] as? Bool
        token.location = dict["location"] as? String
        token.used = dict["used"] as? Bool
        token.card = card
        token.created = parseJSONDate(dict["created"] as? String)
        
        return token
    }
    
    public static func parseError(data: NSData) throws -> OmiseError {
        let dict = try parseJSON(data)
        guard dict["object"] as? String == "error" else {
            throw OmiseError.Unexpected(message: "Unknown API error.", underlying: nil)
        }
        
        guard let location = dict["location"] as? String,
            let code = dict["code"] as? String,
            let message = dict["message"] as? String else {
                throw OmiseError.Unexpected(message: "Unknown API error.", underlying: nil)
        }
        
        return OmiseError.API(code: code, message: message, location: location)
    }
    
    private static func parseJSON(data: NSData) throws -> NSDictionary {
        let jsonObject: AnyObject
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let err {
            throw OmiseError.Unexpected(message: "JSON deserialization failure.", underlying: err)
        }
        
        guard let jsonDict = jsonObject as? NSDictionary else {
            throw OmiseError.Unexpected(message: "Bad JSON response.", underlying: nil)
        }
        
        return jsonDict
    }
    
    private static func parseJSONDate(input: String?) -> NSDate? {
        guard let input = input else { return nil }
        return dateFormatter.dateFromString(input)
    }
}
