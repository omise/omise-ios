import Foundation

public struct PAN {
    let pan: String
    
    public var isValid: Bool {
        guard let brand = self.brand else {
            return false
        }
        
        return brand.validLengths ~= pan.count && validateLuhn()
    }
    
    public var number: String {
        // NNNN-NNXX-XXXX-NNNN
        let replacingRange = (pan.index(pan.startIndex, offsetBy: max(0, pan.count - 10))..<pan.index(pan.endIndex, offsetBy: max(-pan.count, -4)))
        return pan.replacingOccurrences(
            of: "[0-9]", with: "X",
            options: String.CompareOptions.regularExpression,
            range: replacingRange
        )
    }
    
    public var brand: CardBrand? {
        return CardBrand.all
            .filter({ (brand) -> Bool in
                pan.range(of: brand.pattern, options: .regularExpression, range: nil, locale: nil) != nil
            })
            .first
    }
    
    public init(_ pan: String) {
        self.pan = pan.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil)
    }
    
    private func validateLuhn() -> Bool {
        let digits = pan
            .reversed()
            .compactMap({ Int(String($0)) })
        
        guard digits.count == pan.count else { return false }
        
        let oddSum = digits.enumerated()
            .filter({ (index, digit) -> Bool in index % 2 == 0 })
            .map({ (index, digit) -> Int in digit })
        let evenSum = digits.enumerated()
            .filter({ (index, digit) -> Bool in index % 2 != 0 })
            .map({ (index, digit) -> Int in
                let sum = digit * 2
                return sum > 9 ? sum - 9 : sum
            })
        
        let sum = (oddSum + evenSum).reduce(into: 0, { (acc, digit) in acc += digit })
        return sum % 10 == 0
    }
    
    }
}


extension PAN: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        return "PAN: \(isValid ? "✓" : "⨯")\(number) - Brand: \(brand?.description ?? "-")"
    }
    
    public var description: String {
        return "PAN: \(number)"
    }
}

