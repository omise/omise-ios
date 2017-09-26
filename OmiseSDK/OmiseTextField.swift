import Foundation
import UIKit


/// Delegate for receiving SDK-specific text field events.
public protocol OmiseTextFieldValidationDelegate {
    /// A delegate method that will be called when the data validity of the text field is changed.
    func textField(_ field: OmiseTextField, didChangeValidity isValid: Bool)
}


/// Base UITextField subclass for SDK's text fields.
@objc public class OmiseTextField: UITextField {
    public private(set) var previousText: String?
    
    public override var text: String? {
        willSet {
            previousText = text
        }
        didSet {
            // UITextField doesn't send editing changed control event when we set its text property
            textDidChange()
            if !isFirstResponder {
                textColor = isValid ? .black : .red;
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
        super.init(frame: CGRect.zero)
        setup()
    }
    
    private func setup() {
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }
    
    @objc func didBeginEditing() {
        textColor = .black
    }
    
    @objc func didEndEditing() {
        textColor = isValid ? .black : .red
    }
    
    @objc func textDidChange() {
        // no-op for child overrides
    }
}
