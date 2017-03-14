import Foundation
import UIKit


/// UITextField subclass for entering card's CVV number.
@objc public class CardCVVTextField: OmiseTextField {
    private let validLengths = 3...4
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return validLengths ~= text?.characters.count ?? 0
    }
    
    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
        }
    }
    
    public override var isSecureTextEntry: Bool {
        didSet {
            super.isSecureTextEntry = true
        }
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
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup() {
        super.keyboardType = .numberPad
        placeholder = "123"
        super.isSecureTextEntry = true
    }
    
    override func textDidChange() {
        super.textDidChange()
        if text?.characters.count == 5 {
            guard let text = text else { return }
            self.text = String(text.characters.dropLast())
        }
    }
}
