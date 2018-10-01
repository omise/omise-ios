import Foundation
import UIKit


/// UITextField subclass for entering card's CVV number.
@objc public class CardCVVTextField: OmiseTextField {
    private let validLengths = 3...4
    
    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
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
        placeholder = "123"
        
        validator = try! NSRegularExpression(pattern: "\\d{3,4}", options: [])
    }
    
    public override func validate() throws {
        try super.validate()
        
        guard let text = self.text else {
            throw OmiseTextFieldValidationError.emptyText
        }
        if !(validLengths ~= text.count) {
            throw OmiseTextFieldValidationError.invalidData
        }
    }
    
    override func textDidChange() {
        super.textDidChange()
        if text?.count == 5 {
            guard let text = text else { return }
            self.text = String(text.dropLast())
        }
    }
}
