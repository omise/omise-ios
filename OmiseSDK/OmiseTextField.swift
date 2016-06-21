import Foundation
import UIKit

public protocol OmiseTextFieldDelegate {
    func textField(field: OmiseTextField, didChangeValidity isValid: Bool)
}

public class OmiseTextField: UITextField, UITextFieldDelegate {
    private var previousText: String?
    var valid = false
    
    public var validationDelegate: OmiseTextFieldDelegate?
    
    override init(frame: CGRect) {
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
        delegate = self
        addTarget(self, action: #selector(textChanged), forControlEvents: .EditingChanged)
    }
    
    @objc private func textChanged() {
        if previousText?.characters.count >= text?.characters.count {
            previousText = text
            textField(self, textDidDeleted: text!)
            
            return
        }
        previousText = text
        textField(self, textDidChanged: text!)
    }
    
    func textField(textField: OmiseTextField, textDidChanged insertedText: String) {}
    
    func textField(textField: OmiseTextField, textDidDeleted deletedText: String) {}
    
    private func textFieldUIValidate() {
        if valid {
            textColor = UIColor.blackColor()
        } else {
            textColor = UIColor.redColor()
        }
    }
        
    public func textFieldDidBeginEditing(textField: UITextField) {
        textField.textColor = UIColor.blackColor()
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        textFieldUIValidate()
    }
}