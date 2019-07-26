import Foundation
import UIKit


/// UITextField subclass used for entering card's expiry date.
/// `CardExpiryDatePicker` will be set as the default input view.
@objc(OMSCardExpiryDateTextField) @IBDesignable
public class CardExpiryDateTextField: OmiseTextField {
    
    /// Currently selected month, `nil` if no month has been selected.
    public private(set) var selectedMonth: Int? = nil {
        didSet {
            guard let selectedMonth = self.selectedMonth else {
                return
            }
            if !(Calendar.validExpirationMonthRange ~= selectedMonth) {
                self.selectedMonth = nil
            }
            expirationMonthAccessibilityElement.accessibilityValue = self.selectedMonth.map({ CardExpiryDateTextField.spellingOutDateFormatter.monthSymbols[$0 - 1] })
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
    
    
    public var dateSeparatorTextColor: UIColor?
    
    @objc private(set) public var expirationMonthAccessibilityElement: CardExpiryDateTextField.InfoAccessibilityElement!
    @objc private(set) public var expirationYearAccessibilityElement: CardExpiryDateTextField.InfoAccessibilityElement!
    
    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
        }
    }
    
    @available(iOS, unavailable)
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {}
    }
    
    private let maxCreditCardAge = 21
    
    private static let spellingOutDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.creditCardInformationCalendar
        return dateFormatter
    }()
    
    
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
        super.delegate = self
        
        expirationMonthAccessibilityElement = CardExpiryDateTextField.InfoAccessibilityElement(expiryDateTextField: self, component: .month)
        expirationMonthAccessibilityElement.accessibilityLabel = "Expiration month"
        
        expirationYearAccessibilityElement = CardExpiryDateTextField.InfoAccessibilityElement(expiryDateTextField: self, component: .year)
        expirationYearAccessibilityElement.accessibilityLabel = "Expiration year"
        
        #if swift(>=4.2)
        expirationMonthAccessibilityElement.accessibilityTraits.insert(UIAccessibilityTraits.adjustable)
        expirationYearAccessibilityElement.accessibilityTraits.insert(UIAccessibilityTraits.adjustable)        
        #else
        expirationMonthAccessibilityElement.accessibilityTraits |= UIAccessibilityTraitAdjustable
        expirationYearAccessibilityElement.accessibilityTraits |= UIAccessibilityTraitAdjustable
        #endif
        
        validator = try! NSRegularExpression(pattern: "^([0-1]?\\d)/(\\d{1,2})$", options: [])
    }
    
    public override var accessibilityElements: [Any]? {
        get {
            return [expirationMonthAccessibilityElement as Any, expirationYearAccessibilityElement as Any]
        }
        set {}
    }
    
    public override func validate() throws {
        try super.validate()
        
        guard let year = self.selectedYear, let month = self.selectedMonth else {
            throw OmiseTextFieldValidationError.invalidData
        }
        
        let now = Date()
        let calendar = Calendar.creditCardInformationCalendar
        let thisMonth = calendar.component(.month, from: now)
        let thisYear = calendar.component(.year, from: now)
        
        if (year == thisYear && thisMonth > month) || thisYear > year {
            throw OmiseTextFieldValidationError.invalidData
        }
    }
    
    private var isDeletingDateSeparator = false
    
    override func textDidChange() {
        super.textDidChange()
        
        let replacedText = self.text?.replacingOccurrences(of: "[^\\d/]", with: "", options: String.CompareOptions.regularExpression, range: nil)
        guard let text = replacedText,
            !isDeletingDateSeparator else {
                return
        }
        
        let expiryDateComponents = text.split(separator: "/")
        let parsedExpiryMonth = expiryDateComponents.first.flatMap({ Int.init(String($0)) })
        let parsedExpiryYear = expiryDateComponents.count > 1 ? expiryDateComponents.last.flatMap({ Int.init(String($0)) }) : nil
        
        if let expiryMonth = parsedExpiryMonth, expiryMonth > 0 {
            self.selectedMonth = expiryMonth
            
            let expectedDisplayingExpiryMonthText = String(format: "%02d/", expiryMonth)
            if (text != expectedDisplayingExpiryMonthText && parsedExpiryYear == nil)  &&
                (expiryMonth != 1 || expiryDateComponents[0].count == 2) {
                let currentAttributes = defaultTextAttributes
                #if swift(>=4.2)
                let attributedText = NSMutableAttributedString(string: String(format: "%02d/", expiryMonth), attributes: Dictionary(uniqueKeysWithValues: self.defaultTextAttributes.map({ ($0.key, $0.value) })))
                #else
                let attributedText = NSMutableAttributedString(string: String(format: "%02d/", expiryMonth), attributes: Dictionary(uniqueKeysWithValues: self.defaultTextAttributes.map({ (AttributedStringKey(rawValue: $0.key), $0.value) })))
                #endif
                if let separatorTextColor = self.dateSeparatorTextColor {
                    attributedText.addAttribute(.foregroundColor, value: separatorTextColor, range: NSRange(location: attributedText.length - 1, length: 1))
                }
                self.attributedText = attributedText
                typingAttributes = currentAttributes
            }
        }
        if let expiryYear = parsedExpiryYear {
            self.selectedYear = 2000 + expiryYear
        }
        
        if text.count > 5 {
            self.attributedText = self.attributedText?.attributedSubstring(from: NSRange(text.startIndex..<text.index(text.startIndex, offsetBy: 5), in: text))
        }
        
        updateAccessibilityFrames()
    }
    
    public override func deleteBackward() {
        if text?.last == "/" {
            isDeletingDateSeparator = true
            defer {
                isDeletingDateSeparator = false
            }
            super.deleteBackward()
        }
        super.deleteBackward()
        if text == "0" {
            super.deleteBackward()
        }
    }
    
    static let monthStringRegularExpression = try! NSRegularExpression(pattern: "^([0-1]?\\d)", options: [])
    
    public override func replace(_ range: UITextRange, withText text: String) {
        super.replace(range, withText: text)
    }

    public override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        
        guard let copiedText = pasteboard.string, let selectedTextRange = selectedTextRange else {
            return
        }
        let pan = copiedText.replacingOccurrences(
            of: "[^0-9/]",
            with: "",
            options: .regularExpression,
            range: nil)
        isDeletingDateSeparator = true
        replace(selectedTextRange, withText: pan)
        isDeletingDateSeparator = false
        
        guard !text.isNilOrEmpty, let text = self.text else {
            return
        }
        
        let currentAttributes = defaultTextAttributes
        defer {
            typingAttributes = defaultTextAttributes
        }
        
        var parsedSelectedYear: Int? {
            get {
                return selectedYear
            }
            set {
                guard let value = newValue else {
                    return
                }
                if value < 100 {
                    self.selectedYear = 2000 + value
                } else {
                    self.selectedYear = value
                }
            }
        }
        
        if let separatorIndex = text.firstIndex(of: "/") {
            selectedMonth = Int(text[text.startIndex..<separatorIndex])
            if separatorIndex != text.endIndex {
                parsedSelectedYear = Int(text[text.index(after: separatorIndex)...])
            }
        } else if let match = CardExpiryDateTextField.monthStringRegularExpression.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
            match.numberOfRanges == 2 {
            let monthStringNSRange = match.range(at: 1)
            guard let monthStringRange = Range(monthStringNSRange, in: text) else {
                return
            }
            
            selectedMonth = Int(text[monthStringRange])
            parsedSelectedYear = Int(text[monthStringRange.upperBound...])
            
            if monthStringNSRange.length < 2, let selectedMonth = self.selectedMonth {
                if let attributedText = self.attributedText.map(NSMutableAttributedString.init(attributedString:)) {
                    attributedText.mutableString.replaceCharacters(in: monthStringNSRange, with: String(format: "%02d/", selectedMonth))
                    self.attributedText = attributedText
                } else {
                    self.text?.replaceSubrange(monthStringRange, with: String(format: "%02d/", selectedMonth))
                }
            }
        }
        
        if let attributedText = self.attributedText.map(NSMutableAttributedString.init(attributedString:)), let separatorTextColor = self.dateSeparatorTextColor,
            let dateSeparatorIndex = attributedText.string.firstIndex(of: "/") {
            attributedText.addAttribute(.foregroundColor, value: separatorTextColor, range: NSRange(dateSeparatorIndex...dateSeparatorIndex, in: attributedText.string))
            self.attributedText = attributedText
        }
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
        
        let bounds = textRect(forBounds: self.bounds)
        
        if let text = text, text.count >= 5,
            let endOfMonthRange = position(from: beginningOfDocument, offset: 2),
            let startOfYearRange = position(from: endOfMonthRange, offset: 1),
            let monthRange = textRange(from: beginningOfDocument, to: endOfMonthRange),
            let yearRange = textRange(from: startOfYearRange, to: endOfDocument) {
            let monthRect = firstRect(for: monthRange)
            let yearRect = firstRect(for: yearRange)
            expirationMonthFrameInTextfield = CGRect(x: monthRect.origin.x + bounds.minX, y: bounds.minY, width: monthRect.width, height: bounds.height)
            expirationYearFrameInTextfield = CGRect(x: yearRect.origin.x + bounds.minX, y: bounds.minY, width: yearRect.width, height: bounds.height)
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
        
        if #available(iOSApplicationExtension 10.0, *) {
            expirationMonthAccessibilityElement.accessibilityFrameInContainerSpace = expirationMonthFrameInTextfield.integral
            expirationYearAccessibilityElement.accessibilityFrameInContainerSpace = expirationYearFrameInTextfield.integral
        } else {
            expirationMonthAccessibilityElement.accessibilityFrame =
                UIAccessibility.convertToScreenCoordinates(expirationMonthFrameInTextfield.integral, in: self)
            expirationYearAccessibilityElement.accessibilityFrame =
                UIAccessibility.convertToScreenCoordinates(expirationYearFrameInTextfield.integral, in: self)
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
        
        text = String(format: "%02d/%02d", month, year % 100)
        if let attributedText = self.attributedText.map(NSMutableAttributedString.init(attributedString:)), let separatorTextColor = self.dateSeparatorTextColor,
            let dateSeparatorIndex = attributedText.string.firstIndex(of: "/") {
            attributedText.addAttribute(.foregroundColor, value: separatorTextColor, range: NSRange(dateSeparatorIndex...dateSeparatorIndex, in: attributedText.string))
            self.attributedText = attributedText
        }
        
        sendActions(for: .valueChanged)
        
        updateAccessibilityFrames()
    }
}


extension CardExpiryDateTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.length >= 0 else {
            return true
        }
        let maxLength = 5
        
        return maxLength >= (self.text?.count ?? 0) - range.length + string.count
    }
}

