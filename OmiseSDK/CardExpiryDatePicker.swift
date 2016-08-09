import Foundation

// TODO: 👇 only the  data source and delegate needed, we don't need this class.
public final class CardExpiryDatePicker: UIPickerView {
    private let maximumYear = 21
    private let monthPicker = 0
    private let yearPicker = 1
    private let months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    private var years = [Int]()
    
    public var onDateSelected: ((month: Int, year: Int) -> ())?
    public var month: Int = 0
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
        if years.isEmpty {
            let currentYear = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.Year, fromDate: NSDate())
            years = Array(currentYear...(currentYear.advancedBy(maximumYear)))
        }
        
        delegate = self
        dataSource = self
        let month = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.Month, fromDate: NSDate())
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