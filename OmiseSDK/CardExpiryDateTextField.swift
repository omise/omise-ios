import Foundation
import UIKit


/// UITextField subclass used for entering card's expiry date.
/// `CardExpiryDatePicker` will be set as the default input view.
@objc public class CardExpiryDateTextField: OmiseTextField {
    private let maxCreditCardAge = 21
    private let expirationRx = { () -> NSRegularExpression in
        guard let rx = try? NSRegularExpression(pattern: "^(\\d{1,2})/(\\d{1,2})$", options: []) else {
            return NSRegularExpression()
        }
        
        return rx
    }()
    
    /// Currently selected month, `0` if no month has been selected.
    public var selectedMonth: Int = 0
    
    /// Currently selected year, `0` if no year has been selected.
    public var selectedYear: Int = 0
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        let now = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let thisMonth = calendar.component(.month, from: now)
        let thisYear = calendar.component(.year, from: now)
        guard self.selectedYear != 0, self.selectedMonth != 0 else {
            return false
        }
        
        if (self.selectedYear == thisYear) {
            return thisMonth <= self.selectedMonth
        } else {
            return thisYear < self.selectedYear
        }
    }
    
    override public init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        placeholder = "MM/YY"
        let expiryDatePicker = CardExpiryDatePicker() // TODO: Use normal picker delegate.
        expiryDatePicker.onDateSelected = { [weak self] (month: Int, year: Int) in
            self?.text = String(format: "%02d/%d", month, year-2000)
        }
        inputView = expiryDatePicker
    }
    
    override func textDidChange() {
        super.textDidChange()
        
        let text = self.text ?? ""
        let range = NSRange(location: 0, length: text.characters.count)
        guard let match = expirationRx.firstMatch(in: text, options: [], range: range), match.numberOfRanges >= 3 else {
            selectedMonth = 0
            selectedYear = 0
            return
        }
        
        let monthText = textInRange(match.rangeAt(1))
        let yearText = textInRange(match.rangeAt(2))
        selectedMonth = Int(monthText) ?? 0
        selectedYear = Int(yearText)?.advanced(by: 2000) ?? 0
    }
    
    private func textInRange(_ range: NSRange) -> String {
        let text = self.text ?? ""
        let start = text.characters.index(text.startIndex, offsetBy: range.location)
        let end = text.characters.index(start, offsetBy: range.length)
        return text.substring(with: start..<end)
    }
}
