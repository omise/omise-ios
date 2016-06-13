import Foundation
import UIKit

public class OmiseTextField: UITextField, UITextFieldDelegate {
    public var omiseValidatorDelegate: OmiseFormValidatorDelegate?
    private var previousText: String?
    var valid = false
    
    // MARK: Initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        delegate = self
        addTarget(self, action: #selector(OmiseTextField.textChanged), forControlEvents: .EditingChanged)
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
        
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(textField: UITextField) {
        textField.textColor = UIColor.blackColor()
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        textFieldUIValidate()
    }
    
    public class func addInputAccessoryForTextFields(viewController: UIViewController, textFields: [UITextField], previousNextable: Bool = true) {
        for (index, textField) in textFields.enumerate() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                let bundle = NSBundle(forClass: self)
                let previousButton = UIBarButtonItem(image: UIImage(named: "backBarButton", inBundle: bundle, compatibleWithTraitCollection: nil), style: .Plain, target: nil, action: nil)
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.enabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(named: "nextBarButton", inBundle: bundle, compatibleWithTraitCollection: nil), style: .Plain, target: nil, action: nil)
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.enabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                items.appendContentsOf([previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: viewController.view, action: #selector(UIView.endEditing))
            items.appendContentsOf([spacer, doneButton])
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
}