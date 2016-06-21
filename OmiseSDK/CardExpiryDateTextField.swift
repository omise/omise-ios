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
    
    private var month: Int?
    private var year: Int?
    
    public var selectedMonth: Int? { return month }
    public var selectedYear: Int? { return year }
    
    public override var isValid: Bool {
        let now = NSDate()
        guard let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian) else {
            sdkWarn("gregorian calendar not found.")
            return false
        }
        
        let thisMonth = calendar.component(.Month, fromDate: now)
        let thisYear = calendar.component(.Year, fromDate: now)
        guard let year = self.year, month = self.month else {
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
            self?.month = month
            self?.year = year
        }
        inputView = expiryDatePicker
    }
    
    override func textDidChange() {
        super.textDidChange()
        
        let text = self.text ?? ""
        let range = NSRange(location: 0, length: text.characters.count)
        let options = NSMatchingOptions(rawValue: 0)
        guard let match = expirationRx.firstMatchInString(text, options: options, range: range) where match.numberOfRanges >= 3 else {
            month = nil
            year = nil
            return
        }
        
        let monthText = textInRange(match.rangeAtIndex(1))
        let yearText = textInRange(match.rangeAtIndex(2))
        month = Int(monthText)
        year = Int(yearText)
        
        dump("month: \(month) year: \(year)")
    }
    
    private func textInRange(range: NSRange) -> String {
        let text = self.text ?? ""
        let start = text.startIndex.advancedBy(range.location)
        let end = start.advancedBy(range.length)
        return text.substringWithRange(start..<end)
    }
}
