import Foundation
import UIKit

public class CardExpiryDateTextField: OmiseTextField {
    var expirationMonth: Int?
    var expirationYear: Int?
    
    // MARK: Initial
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: Setup
    func setup() {
        placeholder = "MM/YY"
        let expiryDatePicker = CardExpiryDatePicker()
        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
            self.text = String(format: "%02d/%d", month, year-2000)
            self.expirationMonth = month
            self.expirationYear = year
            self.checkValid()
            self.omiseValidatorDelegate?.textFieldDidValidated(self)
        }
        inputView = expiryDatePicker
    }

    func checkValid() {
        guard let month = expirationMonth else {
            valid = false
            return
        }
        
        guard let year = expirationYear else {
            valid = false
            return
        }
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Year], fromDate: date)
        let thisMonth = components.month
        let thisYear = components.year

        if year == thisYear {
            if month < thisMonth {
                valid = false
                return
            }
        }
        
        valid = true
    }
}
