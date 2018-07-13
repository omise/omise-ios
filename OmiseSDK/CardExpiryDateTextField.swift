import Foundation
import UIKit


/// UITextField subclass used for entering card's expiry date.
/// `CardExpiryDatePicker` will be set as the default input view.
@objc public class CardExpiryDateTextField: OmiseTextField {
    private let maxCreditCardAge = 21
    private let expirationRegularExpression = try! NSRegularExpression(pattern: "^(\\d{1,2})/(\\d{1,2})$", options: [])
    
    private static let spellingOutDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.creditCardInformationCalendar
        return dateFormatter
    }()
    
    /// Currently selected month, `nil` if no month has been selected.
    public private(set) var selectedMonth: Int? = nil {
        didSet {
            expirationMonthAccessibilityElement.accessibilityValue = selectedMonth.map({ CardExpiryDateTextField.spellingOutDateFormatter.monthSymbols[$0 - 1] })
        }
    }
    @objc(selectedMonth) public var __selectedMonth: Int {
        return selectedMonth ?? 0
    }
    
    /// Currently selected year, `nil` if no year has been selected.
    public private(set) var selectedYear: Int? = nil {
        didSet {
            expirationYearAccessibilityElement.accessibilityValue = selectedYear.map({ NumberFormatter.localizedString(from: NSNumber(value: $0), number: NumberFormatter.Style.spellOut) })
        }
    }
    @objc(selectedYear) public var __selectedYear: Int {
        return selectedYear ?? 0
    }
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        guard let year = self.selectedYear, let month = self.selectedMonth else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.creditCardInformationCalendar
        let thisMonth = calendar.component(.month, from: now)
        let thisYear = calendar.component(.year, from: now)
        
        if year == thisYear {
            return thisMonth <= month
        } else {
            return thisYear < year
        }
    }
    
    public var expirationMonthAccessibilityElement: CardExpiryDateTextField.InfoAccessibilityElement!
    public var expirationYearAccessibilityElement: CardExpiryDateTextField.InfoAccessibilityElement!
    
    override public init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    private func initializeInstance() {
        placeholder = "MM/YY"
        let expiryDatePicker = CardExpiryDatePicker()
        expiryDatePicker.onDateSelected = { [weak self] (month: Int, year: Int) in
            self?.text = String(format: "%02d/%d", month, year - 2000)
            self?.sendActions(for: UIControlEvents.valueChanged)
        }
        
        inputView = expiryDatePicker
        
        expirationMonthAccessibilityElement = CardExpiryDateTextField.InfoAccessibilityElement(expiryDateTextField: self, component: .month)
        expirationMonthAccessibilityElement.accessibilityTraits |= UIAccessibilityTraitAdjustable
        expirationMonthAccessibilityElement.accessibilityLabel = "Expiration month"
        
        expirationYearAccessibilityElement = CardExpiryDateTextField.InfoAccessibilityElement(expiryDateTextField: self, component: .year)
        expirationYearAccessibilityElement.accessibilityTraits |= UIAccessibilityTraitAdjustable
        expirationYearAccessibilityElement.accessibilityLabel = "Expiration year"
    }
    
    public override var accessibilityElements: [Any]? {
        get {
            return [expirationMonthAccessibilityElement, expirationYearAccessibilityElement]
        }
        set {}
    }
    
    override func textDidChange() {
        super.textDidChange()
        
        let text = self.text ?? ""
        let range =  NSRange(text.startIndex..., in: text)
        guard let match = expirationRegularExpression.firstMatch(in: text, options: [], range: range), match.numberOfRanges >= 3 else {
            selectedMonth = nil
            selectedYear = nil
            return
        }
        
        let monthText = Range(match.range(at: 1), in: text).map({ text[$0] })
        let yearText = Range(match.range(at: 2), in: text).map({ text[$0] })
        selectedMonth = monthText.flatMap({ Int($0) })
        selectedYear = yearText.flatMap({ Int($0) })?.advanced(by: 2000)
        
        updateAccessibilityFrames()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateAccessibilityFrames()
    }
}

extension CardExpiryDateTextField {
    
    private func updateAccessibilityFrames() {
        let expirationMonthFrameInTextfield: CGRect
        let expirationYearFrameInTextfield: CGRect
        if let text = text, text.count >= 5,
            let endOfMonthRange = position(from: beginningOfDocument, offset: 2),
            let startOfYearRange = position(from: endOfMonthRange, offset: 1),
            let monthRange = textRange(from: beginningOfDocument, to: endOfMonthRange),
            let yearRange = textRange(from: startOfYearRange, to: endOfDocument) {
            let monthRect = firstRect(for: monthRange)
            let yearRect = firstRect(for: yearRange)
            expirationMonthFrameInTextfield = CGRect(x: monthRect.origin.x, y: bounds.minY, width: monthRect.width, height: bounds.height)
            expirationYearFrameInTextfield = CGRect(x: yearRect.origin.x, y: bounds.minY, width: yearRect.width, height: bounds.height)
        } else if let expiryDateTextFieldAttributedPlaceholder = attributedPlaceholder, expiryDateTextFieldAttributedPlaceholder.length >= 5 {
            let mmSize = expiryDateTextFieldAttributedPlaceholder.attributedSubstring(from: NSRange(location: 0, length: 2)).size()
            let slashSize = expiryDateTextFieldAttributedPlaceholder.attributedSubstring(from: NSRange(location: 2, length: 1)).size()
            let yySize = expiryDateTextFieldAttributedPlaceholder.attributedSubstring(from: NSRange(location: 3, length: 2)).size()
            
            let (monthFrame, remainingFromMonthFrame) = bounds.divided(atDistance: mmSize.width, from: .minXEdge)
            let (_, remainingFrame) = remainingFromMonthFrame.divided(atDistance: slashSize.width, from: .minXEdge)
            let (yearFrame, _) = remainingFrame.divided(atDistance: yySize.width, from: .minXEdge)
            
            expirationMonthFrameInTextfield = monthFrame
            expirationYearFrameInTextfield = yearFrame
        } else {
            let mmSize = NSAttributedString(string: "MM", attributes: [.font: font ?? UIFont.preferredFont(forTextStyle: .body)]).size()
            let slashSize = NSAttributedString(string: "/", attributes: [.font: font ?? UIFont.preferredFont(forTextStyle: .body)]).size()
            let yySize = NSAttributedString(string: "YY", attributes: [.font: font ?? UIFont.preferredFont(forTextStyle: .body)]).size()
            
            let (monthFrame, remainingFromMonthFrame) = bounds.divided(atDistance: mmSize.width, from: .minXEdge)
            let (_, remainingFrame) = remainingFromMonthFrame.divided(atDistance: slashSize.width, from: .minXEdge)
            let (yearFrame, _) = remainingFrame.divided(atDistance: yySize.width, from: .minXEdge)
            
            expirationMonthFrameInTextfield = monthFrame
            expirationYearFrameInTextfield = yearFrame
        }
        
        if #available(iOS 10.0, *) {
            expirationMonthAccessibilityElement.accessibilityFrameInContainerSpace = expirationMonthFrameInTextfield.integral
            expirationYearAccessibilityElement.accessibilityFrameInContainerSpace = expirationYearFrameInTextfield.integral
        } else {
            expirationMonthAccessibilityElement.accessibilityFrame =
                UIAccessibilityConvertFrameToScreenCoordinates(expirationMonthFrameInTextfield.integral, self)
            expirationYearAccessibilityElement.accessibilityFrame =
                UIAccessibilityConvertFrameToScreenCoordinates(expirationYearFrameInTextfield.integral, self)
        }
    }

    
    public class InfoAccessibilityElement: UIAccessibilityElement {
        enum Component {
            case month
            case year
        }
        
        let component: Component
        unowned let expiryDateTextField: CardExpiryDateTextField
        
        init(expiryDateTextField textField: CardExpiryDateTextField, component: Component) {
            self.expiryDateTextField = textField
            self.component = component
            
            super.init(accessibilityContainer: textField)
        }
        
        public override func accessibilityIncrement() {
            switch component {
            case .month:
                expiryDateTextField.selectedMonth = min(12, (expiryDateTextField.selectedMonth ?? Calendar.creditCardInformationCalendar.component(.month, from: Date())) + 1)
            case .year:
                expiryDateTextField.selectedYear = (expiryDateTextField.selectedYear ?? Calendar.creditCardInformationCalendar.component(.year, from: Date())) + 1
            }
            expiryDateTextField.updateText()
        }
        
        public override func accessibilityDecrement() {
            switch component {
            case .month:
                expiryDateTextField.selectedMonth = max(1, (expiryDateTextField.selectedMonth ?? Calendar.creditCardInformationCalendar.component(.month, from: Date())) - 1)
            case .year:
                expiryDateTextField.selectedYear = (expiryDateTextField.selectedYear ?? Calendar.creditCardInformationCalendar.component(.year, from: Date())) - 1
            }
            expiryDateTextField.updateText()
        }
    }
    
    private func updateText() {
        let month = selectedMonth ?? Calendar.creditCardInformationCalendar.component(.month, from: Date())
        let year = selectedYear ?? Calendar.creditCardInformationCalendar.component(.year, from: Date())
        
        text = String(format: "%02d/%d", month, year - 2000)
        sendActions(for: UIControlEvents.valueChanged)
        
        updateAccessibilityFrames()
    }
}

