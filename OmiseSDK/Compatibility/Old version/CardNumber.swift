import Foundation


/// Utility class for working with credit card numbers.
@objc(OMSCardNumber) public final class CardNumber: NSObject {
    
    /**
     Normalize credit card number by removing all non-number characters.
     - returns: String of normalized credit card number. eg. *4242424242424242*
     */
    @objc public static func normalize(_ pan: String) -> String {
        return pan.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil)
    }
    
    /**
     Determine credit card brand from given credit card number.
     - returns: valid `CardBrand` or nil if it cannot be determined.
     - seealso: CardBrand
     */
    public static func brand(of pan: String) -> CardBrand? {
        return CardBrand.all
            .filter({ (brand) -> Bool in pan.range(of: brand.pattern, options: .regularExpression, range: nil, locale: nil) != nil })
            .first
    }
    
    @objc(brandForPan:) public static func __brand(_ pan: String) -> Int {
        return brand(of: pan)?.rawValue ?? NSNotFound
    }
    
    
    /**
     Formats given credit card number into a human-friendly string by inserting spaces
     after every 4 digits. ex. `4242 4242 4242 4242`
     - returns: Formatted credit card number string.
     */
    @objc public static func format(_ pan: String) -> String {
        var result = ""
        for (i, digit) in normalize(pan).enumerated() {
            if i > 0 && i % 4 == 0 {
                result += " "
            }
            
            result.append(digit)
        }
        
        return result
    }
    
    /**
     Validate credit card number using the Luhn algorithm.
     - returns: `true` if the Luhn check passes, otherwise `false`.
     */
    @objc public static func luhn(_ pan: String) -> Bool {
        let chars = normalize(pan)
        let digits = chars
            .reversed()
            .compactMap { (char) -> Int? in Int(String(char)) }
        
        guard digits.count == chars.count else { return false }
        
        let oddSum = digits.enumerated()
            .filter { (index, digit) -> Bool in index % 2 == 0 }
            .map { (index, digit) -> Int in digit }
        let evenSum = digits.enumerated()
            .filter { (index, digit) -> Bool in index % 2 != 0 }
            .map { (index, digit) -> Int in digit * 2 }
            .map { (sum) -> Int in sum > 9 ? sum - 9 : sum }
        
        let sum = (oddSum + evenSum).reduce(0) { (acc, digit) -> Int in acc + digit }
        return sum % 10 == 0
    }
    
    /**
     Validate credit card number by using the Luhn algorithm and checking that the length
     is within credit card brand's valid range.
     - returns: `true` if the given credit card number is valid for all available checks, otherwise `false`.
     */
    @objc public static func validate(_ pan: String) -> Bool {
        let normalized = normalize(pan)
        
        guard let brand = brand(of: normalized) else { return false }
        return brand.validLengths ~= normalized.count && luhn(normalized)
    }
}
