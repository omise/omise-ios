import Foundation

@objc(OMSCardBrand) public enum CardBrand: Int {
    public static let all: [CardBrand] = [
        AMEX,
        Diners,
        JCB,
        Laser,
        Visa,
        MasterCard,
        Maestro,
        Discover
    ]
    
    case AMEX
    case Diners
    case JCB
    case Laser
    case Visa
    case MasterCard
    case Maestro
    case Discover
    
    /// Regular expression pattern that can detect cards issued by the brand.
    public var pattern: String {
        switch self {
        case .AMEX:
            return "^3[47]"
        case .Diners:
            return "^3(0[0-5]|6)"
        case .JCB:
            return "^35(2[89]|[3-8])"
        case .Laser:
            return "^(6304|670[69]|6771)"
        case .Visa:
            return "^4"
        case .MasterCard:
            return "^(5[1-5]|2(2(2[1-9]|[3-9])|[3-6]|7(0|1|20)))"
        case .Maestro:
            return "^(5018|5020|5038|6304|6759|676[1-3])"
        case .Discover:
            return "^(6011|622(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9[0-1][0-9]|92[0-5]|64[4-9])|65)"
        }
    }
    
    /// Range of valid card number lengths for cards issued by the brand.
    public var validLengths: ClosedRange<Int> {
        switch self {
        case .AMEX:
            return 15...15
        case .Diners:
            return 14...14
        case .JCB:
            return 16...16
        case .Laser:
            return 16...19
        case .Visa:
            return 16...16
        case .MasterCard:
            return 16...16
        case .Maestro:
            return 12...19
        case .Discover:
            return 16...16
        }
    }
}


@objc(OMSCardBrandHelper) public final class __OMSCardBrand: NSObject {
    @objc(patternForBrand:) public static func __patternForBrand(brand: CardBrand) -> String {
        return brand.pattern
    }
    
    @objc(validLengthsForBrand:) public static func __validLengthsForBrand(brand: CardBrand) -> NSRange {
        let range = brand.validLengths
        
        return NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
    }
}

