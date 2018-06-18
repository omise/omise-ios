import Foundation

public struct PAN {
    let pan: String
    
    public var number: String {
        // xxxx-xx
        let replacingRange = (pan.index(pan.startIndex, offsetBy: 6)..<pan.index(pan.endIndex, offsetBy: -4))
        return pan.replacingOccurrences(of: "[0-9]", with: "X", options: String.CompareOptions.regularExpression, range: replacingRange)
    }
    
    public var brand: CardBrand? {
        return CardBrand.all
            .filter({ (brand) -> Bool in
                number.range(of: brand.pattern, options: .regularExpression, range: nil, locale: nil) != nil
            })
            .first
    }
    
    public init(_ pan: String) {
        self.pan = pan
    }
}

extension PAN: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        return "PAN: \(number) - Brand: \(brand?.description ?? "-")"
    }
    
    public var description: String {
        return "PAN: \(number)"
    }
}

