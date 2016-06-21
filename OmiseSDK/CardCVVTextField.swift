import Foundation
import UIKit

public class CardCVVTextField: OmiseTextField, UITextFieldDelegate {
    private let maxLength = 3
    
    public override var isValid: Bool {
        return text?.characters.count >= maxLength
    }
    
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
    
    func setup() {
        keyboardType = .NumberPad
        placeholder = "123"
        secureTextEntry = true
        delegate = self // TODO: 👈 remove, replace with mask instead
    }
   
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
