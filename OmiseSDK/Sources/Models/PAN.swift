import Foundation

/// A credit card `PAN` value.
public struct PAN {
    let pan: String
    
    /// Returns true if the PAN is a valid PAN number
    public var isValid: Bool {
        guard let brand = self.brand else {
            return false
        }
        
        return brand.validLengths ~= pan.count && validateLuhn()
    }
    
    /// The masked PAN number.
    ///
    /// The returned number will be masked the numbers in the middle of the PAN.
    /// This helps prevent the unintentional leaked PAN number in the log or system
    public var number: String {
        // NNNN-NNXX-XXXX-NNNN
        let startIndex = pan.index(pan.startIndex, offsetBy: max(0, pan.count - 10))
        let endEndex = pan.index(pan.endIndex, offsetBy: max(-pan.count, -4))
        let replacingRange = startIndex..<endEndex
        return pan.replacingOccurrences(
            of: "[0-9]",
            with: "X",
            options: String.CompareOptions.regularExpression,
            range: replacingRange
        )
    }
    
    /// A card network brand of this PAN
    public var brand: CardBrand? {
        return CardBrand.all.first { brand -> Bool in
            pan.range(of: brand.pattern, options: .regularExpression, range: nil, locale: nil) != nil
        }
    }
    
    /// The suggested of where the space should be displayed string indexes
    public var suggestedSpaceFormattedIndexes: IndexSet {
        return IndexSet(stride(from: 4, to: 19, by: 4))
    }
    
    /// The last 4 digits of the PAN number
    public var lastDigits: String {
        return String(pan.suffix(4))
    }
    
    /// Initializes a `PAN` with the given PAN number string
    public init(_ pan: String) {
        self.pan = pan.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    private func validateLuhn() -> Bool {
        let digits = pan
            .reversed()
            .compactMap { Int(String($0)) }
        
        guard digits.count == pan.count else { return false }
        
        let oddSum = digits.enumerated()
            .filter { (index, _) -> Bool in index.isMultiple(of: 2) }
            .map { (_, digit) -> Int in digit }
        let evenSum = digits.enumerated()
            .filter { (index, _) -> Bool in !index.isMultiple(of: 2) }
            .map { (_, digit) -> Int in
                let sum = digit * 2
                return sum > 9 ? sum - 9 : sum
            }
        
        let sum = (oddSum + evenSum).reduce(into: 0) { (acc, digit) in acc += digit }
        return sum.isMultiple(of: 10)
    }
    
    /// The suggested of where the space should be displayed string indexes for a given PAN string
    /// - seealso: PAN.suggestedSpaceFormattedIndexes
    public static func suggestedSpaceFormattedIndexesForPANPrefix(_ panPrefix: String) -> IndexSet {
        return PAN(panPrefix).suggestedSpaceFormattedIndexes
    }
}

extension PAN {
    static func ~= (brand: CardBrand, pan: PAN) -> Bool {
        return brand.pattern ~= pan
    }
    
    static func ~= (pattern: String, pan: PAN) -> Bool {
        return pan.pan.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
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
