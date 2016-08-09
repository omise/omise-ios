import Foundation

// TODO: 👇 only the  data source and delegate needed, we don't need this class.

/// A UIPickerView subclass UI for picking the card expiry date.
public final class CardExpiryDatePicker: UIPickerView {
    private static let maximumYear = 21
    private let monthPicker = 0
    private let yearPicker = 1
    private let months: [String] = {
        let validRange = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.maximumRangeOfUnit(NSCalendarUnit.Month)
        let validMonthRange = validRange.location..<validRange.location.advancedBy(validRange.length)
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumIntegerDigits = 2
        
        return validMonthRange.map({ formatter.stringFromNumber($0)! })
    }()

    private let years: [Int] = {
        let currentYear = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.Year, fromDate: NSDate())
        return Array(currentYear...(currentYear.advancedBy(maximumYear)))
    }()
    
    /// A callback closure that will be called when the selected card expiry date is changed. 
    public var onDateSelected: ((month: Int, year: Int) -> ())?
    /// Currently selected month value
    public var month: Int = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.Month, fromDate: NSDate())
    /// Currently selected year value
    public var year: Int = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
        dataSource = self
        selectRow(month - 1, inComponent: 0, animated: false)
    }
}

extension CardExpiryDatePicker: UIPickerViewDataSource {
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case monthPicker:
            return months.count
        case yearPicker:
            return years.count
        default:
            return 0
        }
    }
}

extension CardExpiryDatePicker: UIPickerViewDelegate {
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case monthPicker:
            return months[row]
        case yearPicker:
            return "\(years[row])"
        default:
            return nil
        }
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = selectedRowInComponent(monthPicker) + 1
        let year = years[selectedRowInComponent(yearPicker)]
        if let block = onDateSelected {
            block(month: month, year: year)
        }
        
        self.month = month
        self.year = year
    }
}

