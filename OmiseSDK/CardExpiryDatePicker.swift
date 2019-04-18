import Foundation


/// UIPickerView subclass pre-configured for picking card expiration month and year.
@objc(OMSCardExpiryDatePicker) public
class CardExpiryDatePicker: UIPickerView {
    
    /// Callback function that will be called when picker value changes.
    public var onDateSelected: ((_ month: Int, _ year: Int) -> ())?
    /// Currently selected month.
    public var month: Int = Calendar.creditCardInformationCalendar.component(.month, from: Date())
    /// Currently selected year.
    public var year: Int = 0
    
    
    private static let maximumYear = 21
    private static let monthPicker = 0
    private static let yearPicker = 1
    
    private let months: [String] = {
        let validRange = Calendar.creditCardInformationCalendar.maximumRange(of: Calendar.Component.month) ?? Range<Int>(1...12)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumIntegerDigits = 2
        #if swift(>=4.2)
        return validRange.map({ formatter.string(from: $0 as NSNumber)! })
        #else
        return Array(validRange.lowerBound..<validRange.upperBound).map({ formatter.string(from: $0 as NSNumber)! })
        #endif
    }()
    
    private let years: [Int] = {
        let currentYear = Calendar.creditCardInformationCalendar.component(.year, from: Date())
        return Array(currentYear...(currentYear.advanced(by: maximumYear)))
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    private func initializeInstance() {
        delegate = self
        dataSource = self
        selectRow(month - 1, inComponent: 0, animated: false)
    }
}

extension CardExpiryDatePicker: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case CardExpiryDatePicker.monthPicker:
            return months.count
        case CardExpiryDatePicker.yearPicker:
            return years.count
        default:
            return 0
        }
    }
}

extension CardExpiryDatePicker: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case CardExpiryDatePicker.monthPicker:
            return months[row]
        case CardExpiryDatePicker.yearPicker:
            return String(years[row])
        default:
            return nil
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = selectedRow(inComponent: CardExpiryDatePicker.monthPicker) + 1
        let year = years[selectedRow(inComponent: CardExpiryDatePicker.yearPicker)]
        if let block = onDateSelected {
            block(month, year)
        }
        
        self.month = month
        self.year = year
    }
}

