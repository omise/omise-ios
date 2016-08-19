import Foundation
import UIKit


/// Delegate for receiving SDK-specific text field events.
public protocol OmiseTextFieldValidationDelegate {
    /// A delegate method that will be called when the data validity of the text field is changed.
    func textField(field: OmiseTextField, didChangeValidity isValid: Bool)
}


/// Base UITextField subclass for SDK's text fields.
public class OmiseTextField: UITextField {
    public private(set) var previousText: String?
    
    public override var text: String? {
        willSet {
            previousText = text
        }
        didSet {
            // UITextField doesn't send editing changed control event when we set its text property
            textDidChange()
            if !isFirstResponder() {
                textColor = isValid ? .blackColor() : .redColor();
            }
        }
    }
    
    /// Boolean indicating wether current input is valid or not.
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
        addTarget(self, action: #selector(textDidChange), forControlEvents: .EditingChanged)
        addTarget(self, action: #selector(didBeginEditing), forControlEvents: .EditingDidBegin)
        addTarget(self, action: #selector(didEndEditing), forControlEvents: .EditingDidEnd)
    }
    
    func didBeginEditing() {
        textColor = .blackColor()
    }
    
    func didEndEditing() {
        textColor = isValid ? .blackColor() : .redColor();
    }
    
    func textDidChange() {
        // no-op for child overrides
    }
}
