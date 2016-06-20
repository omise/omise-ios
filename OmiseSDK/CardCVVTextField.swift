import Foundation
import UIKit

public class CardCVVTextField: OmiseTextField {
    var cvv: String = ""
    private let maxLength = 3
    
    // MARK: Initial
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: Setup
    func setup() {
        keyboardType = .NumberPad
        placeholder = "123"
        secureTextEntry = true
    }
    
    func checkValid() {
        if  cvv.characters.count >= maxLength  {
            valid = true
        } else {
            valid = false
        }
        omiseValidatorDelegate?.textFieldDidValidated(self)
    }
    
    override func textField(textField: OmiseTextField, textDidChanged insertedText: String) {
        cvv = insertedText
        checkValid()
    }
    
    override func textField(textField: OmiseTextField, textDidDeleted deletedText: String) {
        cvv = deletedText
        checkValid()
    }
        
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
