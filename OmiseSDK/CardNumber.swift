import Foundation


/// A utility class for a `Card` number calculation
@objc(OMSCardNumber) public final class CardNumber: NSObject {
    
    /**
     Normalize the credit card PAN number, remove any characters that are not the number.
     - returns: Normalized PAN number. eg. *4242424242424242*
     */
    @objc public static func normalize(pan: String) -> String {
        return pan.stringByReplacingOccurrencesOfString(
            "[^0-9]",
            withString: "",
            options: .RegularExpressionSearch,
            range: nil)
    }
    
    /**
     Determine the credit card network brand from given credit card number
     - returns: Credit card network brand, nil if it's not recognized by Omise.
     - seealso: CardBrand
     */
    public static func brand(pan: String) -> CardBrand? {
        return CardBrand.all
            .filter({ (brand) -> Bool in pan.rangeOfString(brand.pattern, options: .RegularExpressionSearch, range: nil, locale: nil) != nil })
            .first
    }
    
    @objc(brandForPan:) public static func __brand(pan: String) -> Int {
        return brand(pan)?.rawValue ?? NSNotFound
    }
    
    
    /**
     Format string of given credit card number.
     - returns: Return a formatted string of given credit card number. eg. `4242 4242 4242 4242`
     */
    @objc public static func format(pan: String) -> String {
        var result = ""
        for (i, digit) in normalize(pan).characters.enumerate() {
            if i > 0 && i % 4 == 0 {
                result += " "
            }
            
            result.append(digit)
        }
        
        return result
    }
    
    /**
     Verify the luhn number of given credit card number
     - returns: true if the luhn number of given credit card number is valid.
     */
    @objc public static func luhn(pan: String) -> Bool {
        let chars = normalize(pan).characters
        let digits = chars
            .reverse()
            .map { (char) -> Int in Int(String(char)) ?? -1 }
        
        guard !digits.contains(-1) else { return false }
        
        let oddSum = digits.enumerate()
            .filter { (index, digit) -> Bool in index % 2 == 0 }
            .map { (index, digit) -> Int in digit }
        let evenSum = digits.enumerate()
            .filter { (index, digit) -> Bool in index % 2 != 0 }
            .map { (index, digit) -> Int in digit * 2 }
            .map { (sum) -> Int in sum > 9 ? sum - 9 : sum }
        
        let sum = (oddSum + evenSum).reduce(0) { (acc, digit) -> Int in acc + digit }
        return sum % 10 == 0
    }
    
    /**
     Validate the given credit card number. The validate method will validate the luhn number and the lenght of the credit card.
     - returns: true if the given credit card number is valid
     */
    @objc public static func validate(pan: String) -> Bool {
        let normalized = normalize(pan)
        
        guard let brand = brand(normalized) else { return false }
        return brand.validLengths ~= normalized.characters.count && luhn(normalized)
    }
}
