import Foundation
import UIKit

public protocol OmiseTextFieldValidationDelegate {
    func textField(field: OmiseTextField, didChangeValidity isValid: Bool)
}

public class OmiseTextField: UITextField {
    public var isValid: Bool {
        // child-class override hook to provide validation logic.
        return true
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    private func setup() {
        // addTarget(self, action: #selector(textChanged), forControlEvents: .EditingChanged)
        addTarget(self, action: #selector(OmiseTextField.textDidChange), forControlEvents: .EditingChanged)
        addTarget(self, action: #selector(OmiseTextField.didBeginEditing), forControlEvents: .EditingDidBegin)
        addTarget(self, action: #selector(OmiseTextField.didEndEditing), forControlEvents: .EditingDidEnd)
    }
    
    func didBeginEditing() {
        textColor = .blackColor()
    }
    
    func didEndEditing() {
        // TODO: 👇 unnecessary?
        textColor = isValid ? .blackColor() : .redColor();
    }
    
    func textDidChange() {
        textColor = isValid ? .blackColor() : .redColor();
    }
}
