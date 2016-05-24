import Foundation

public final class PANUtils {
    public static func brand(pan: String) -> CardBrand? {
        return CardBrand.all
            .filter({ (brand) -> Bool in pan.rangeOfString(brand.pattern, options: .RegularExpressionSearch, range: nil, locale: nil) != nil })
            .first
    }
    
    public static func normalize(pan: String) -> String {
        return pan.stringByReplacingOccurrencesOfString(
            "[^0-9]",
            withString: "",
            options: .RegularExpressionSearch,
            range: nil)
    }
    
    public static func luhn(pan: String) -> Bool {
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
    
    public static func validate(pan: String) -> Bool {
        let normalized = normalize(pan)
        
        guard let brand = brand(normalized) else { return false }
        return brand.validLengths ~= normalized.characters.count && luhn(normalized)
    }
}
