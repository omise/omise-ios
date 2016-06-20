import Foundation
import UIKit

public class CardExpiryDateTextField: OmiseTextField {
    private let separator = "/"
    private let splitLength = 2
    private let maxLength = 4
    private let maxCreditCardAge = 21
    
    var expirationMonth: Int?
    var expirationYear: Int?
    
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
    
    func setup() {
        placeholder = "MM/YY"
        let expiryDatePicker = CardExpiryDatePicker()
        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
            self.text = String(format: "%02d/%d", month, year-2000)
            self.expirationMonth = month
            self.expirationYear = year
            self.checkValidFromPicker()
            self.omiseValidatorDelegate?.textFieldDidValidated(self)
        }
        inputView = expiryDatePicker
    }
    
    override func textField(textField: OmiseTextField, textDidChanged insertedText: String) {
        if insertedText.characters.count > maxLength {
            checkValidFromTextDidChanged(insertedText)
            omiseValidatorDelegate?.textFieldDidValidated(self)
            return
        }
        
        var cardExpiryDateString = ""
        var text = insertedText
        text = text.stringByReplacingOccurrencesOfString(separator, withString: "", options: .LiteralSearch, range: nil)
        while text.characters.count > 0 {
            let index = text.startIndex.advancedBy(min(text.characters.count, splitLength))
            let subString = text.substringToIndex(index)
            cardExpiryDateString += subString
            
            if subString.characters.count == splitLength {
                cardExpiryDateString += separator
            }
            
            text = text.substringFromIndex(index)
        }
        
        textField.text = cardExpiryDateString
        checkValidFromTextDidChanged(textField.text)
        omiseValidatorDelegate?.textFieldDidValidated(self)
    }
    
    override func textField(textField: OmiseTextField, textDidDeleted deletedText: String) {
        checkValidFromTextDidChanged(deletedText)
        omiseValidatorDelegate?.textFieldDidValidated(self)
    }

    private func checkValidFromPicker() {
        valid = false
        guard let month = expirationMonth else { return }
        guard let year = expirationYear else { return }
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Year], fromDate: date)
        let thisMonth = components.month
        let thisYear = components.year
        
        if year == thisYear {
            if month < thisMonth {
                return
            }
        }
        
        valid = true
    }
    
    private func checkValidFromTextDidChanged(expiryDate: String?) {
        valid = false
        guard let expiryDate = expiryDate else { return }
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Year], fromDate: date)
        let thisMonth = components.month
        let thisYear = components.year
        
        let expiryDateArr = expiryDate.componentsSeparatedByString(separator)
        if expiryDateArr.count > 1 {
            guard let month = Int(expiryDateArr[0]) else {
                return
            }
            guard let year = Int(expiryDateArr[1]) else {
                return
            }
            
            let expiryYear = year+2000
            guard month > 0 && month <= 12 else {
                return
            }
            
            guard expiryYear >= thisYear && expiryYear < thisYear+maxCreditCardAge else {
                return
            }
            
            if expiryYear == thisYear {
                if month < thisMonth {
                    return
                }
            }
            
            expirationMonth = month
            expirationYear = year
            valid = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == separator{
            return false
        }
        
        if string.characters.count == 0 && range.length == 1 {
            if range.location == maxLength {
                deleteBackward()
            }
        }
        
        if(range.length + range.location > maxLength) {
            return false
        }
        
        return true
    }
}
