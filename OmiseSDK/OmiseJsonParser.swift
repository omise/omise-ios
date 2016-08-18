import Foundation


/// Utility class for parsing JSON data returned from Omise API.
@objc(OMSJSONParser) public final class OmiseJsonParser: NSObject {
    /// Date formatter used for formatting the date fields returned from Omise API.
    /// Dates from Omise API follows the ISO8601 standard.
    @objc public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
    /**
     Parses Token data returned from Omise API.
     - parameter data: `NSData` with Token JSON returned from Omise API.
     - returns: An `OmiseToken` instance parsed from JSON data.
     - throws: `OmiseError.Unexpected` if JSON parsing failed.
     */
    @objc public static func parseToken(from data: Data) throws -> OmiseToken {
        let dict = try parseJSON(from: data)
        guard dict["object"] as? String == "token" else {
            throw OmiseError.unexpected(message: "Bad JSON response.", underlying: nil)
        }
        guard let cardDict = dict["card"] as? NSDictionary else {
            throw OmiseError.unexpected(message: "Bad JSON response.", underlying: nil)
        }
        
        let card = OmiseCard()
        card.cardId = cardDict["id"] as? String
        card.livemode = cardDict["livemode"] as? Bool ?? false
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
        card.securityCodeCheck = cardDict["security_code_check"] as? Bool ?? false
        card.created = parseJSONDate(cardDict["created"] as? String)
        
        let token = OmiseToken()
        token.tokenId = dict["id"] as? String
        token.livemode = dict["livemode"] as? Bool ?? false
        token.location = dict["location"] as? String
        token.used = dict["used"] as? Bool ?? false
        token.card = card
        token.created = parseJSONDate(dict["created"] as? String)
        
        return token
    }
    
    /**
     Parses an API error object returned from Omise API.
     - parameter data: `NSData` with Error JSON returned from Omise API.
     - returns: `OmiseError` value.
     - throws: `OmiseError.Unexpected` if JSON parsing failed.
     */
    @objc(parseError:error:) public static func parseError(from data: Data) throws -> Error {
        let dict = try parseJSON(from: data)
        guard dict["object"] as? String == "error" else {
            throw OmiseError.unexpected(message: "Unknown API error.", underlying: nil)
        }
        
        guard let location = dict["location"] as? String,
            let code = dict["code"] as? String,
            let message = dict["message"] as? String else {
                throw OmiseError.unexpected(message: "Unknown API error.", underlying: nil)
        }
        
        return OmiseError.api(code: code, message: message, location: location)
    }
    
    
    private static func parseJSON(from data: Data) throws -> NSDictionary {
        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let err {
            throw OmiseError.unexpected(message: "JSON deserialization failure.", underlying: err)
        }
        
        guard let jsonDict = jsonObject as? NSDictionary else {
            throw OmiseError.unexpected(message: "Bad JSON response.", underlying: nil)
        }
        
        return jsonDict
    }
    
    private static func parseJSONDate(_ input: String?) -> Date? {
        return input.flatMap(dateFormatter.date(from:))
    }
}

