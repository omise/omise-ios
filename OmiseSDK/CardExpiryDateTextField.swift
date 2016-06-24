import Foundation
import UIKit

public class CardExpiryDateTextField: OmiseTextField {
    private let maxCreditCardAge = 21
    private let expirationRx = { () -> NSRegularExpression in
        let options = NSRegularExpressionOptions(rawValue: 0)
        guard let rx = try? NSRegularExpression(pattern: "^(\\d{1,2})/(\\d{1,2})$", options: options) else {
            return NSRegularExpression()
        }
        
        return rx
    }()
    
    public private(set) var selectedMonth: Int? = nil
    public private(set) var selectedYear: Int? = nil
    
    public override var isValid: Bool {
        let now = NSDate()
        guard let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian) else {
            sdkWarn("gregorian calendar not found.")
            return false
        }
        
        let thisMonth = calendar.component(.Month, fromDate: now)
        let thisYear = calendar.component(.Year, fromDate: now)
        guard let year = self.selectedYear, month = self.selectedMonth else {
            return false
        }
        
        if (year == thisYear) {
            return thisMonth <= month
        } else {
            return thisYear < year
        }
    }
    
    override public init() {
        super.init(frame: CGRectZero)
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
        let options = NSMatchingOptions(rawValue: 0)
        guard let match = expirationRx.firstMatchInString(text, options: options, range: range) where match.numberOfRanges >= 3 else {
            selectedMonth = nil
            selectedYear = nil
            return
        }
        
        let monthText = textInRange(match.rangeAtIndex(1))
        let yearText = textInRange(match.rangeAtIndex(2))
        selectedMonth = Int(monthText)
        selectedYear = Int(yearText)?.advancedBy(2000)
    }
    
    private func textInRange(range: NSRange) -> String {
        let text = self.text ?? ""
        let start = text.startIndex.advancedBy(range.location)
        let end = start.advancedBy(range.length)
        return text.substringWithRange(start..<end)
    }
}
