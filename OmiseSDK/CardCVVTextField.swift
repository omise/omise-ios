import Foundation
import UIKit


/// UITextField subclass for entering card's CVV number.
@objc public class CardCVVTextField: OmiseTextField {
    private let validLengths = 3...4
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return validLengths ~= text?.count ?? 0
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
        initializeInstance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    override public init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        super.keyboardType = .numberPad
        super.isSecureTextEntry = true
        placeholder = "123"
    }
    
    override func textDidChange() {
        super.textDidChange()
        if text?.count == 5 {
            guard let text = text else { return }
            self.text = String(text.dropLast())
        }
    }
}
