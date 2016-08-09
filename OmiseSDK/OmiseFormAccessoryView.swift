import Foundation

@objc(OMSOmiseFormAccessoryView) public class OmiseFormAccessoryView: UIToolbar {
    private var textFields = [UITextField]() {
        willSet {
            textFields.forEach { (textField) in
                textField.removeTarget(self, action: #selector(textFieldDidBeginEditing), forControlEvents: UIControlEvents.EditingDidBegin)
            }
        }
        didSet {
            textFields.forEach { (textField) in
                textField.addTarget(self, action: #selector(textFieldDidBeginEditing), forControlEvents: UIControlEvents.EditingDidBegin)
                textField.inputAccessoryView = self
            }
        }
    }
    private var currentTextField: UITextField?
    private var previousButton = UIBarButtonItem()
    private var nextButton = UIBarButtonItem()
    
    public init() {
        super.init(frame: CGRectZero)
        self.sizeToFit()
        
        let bundle = NSBundle(forClass: OmiseFormAccessoryView.self)
        
        previousButton.image = UIImage(named: "backBarButton", inBundle: bundle, compatibleWithTraitCollection: nil)
        previousButton.style = .Plain
        previousButton.width = 30
        previousButton.target = self
        previousButton.action = #selector(previousButtonTapped)
        
        nextButton.image = UIImage(named: "nextBarButton", inBundle: bundle, compatibleWithTraitCollection: nil)
        nextButton.style = .Plain
        nextButton.width = 30
        nextButton.target = self
        nextButton.action = #selector(nextButtonTapped)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func attachToTextFields(textFields: [UITextField], inViewController viewController: UIViewController) {
        self.textFields = textFields
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: viewController.view, action: #selector(UIView.endEditing))
        
        let items = [previousButton, nextButton, spacer, doneButton]
        self.setItems(items, animated: false)
    }
    
    @objc private func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
        previousButton.enabled = textField != textFields.first
        nextButton.enabled = textField != textFields.last
    }
    
    @objc private func previousButtonTapped(button: UIBarButtonItem) {
        guard let currentTextField = currentTextField, let index = textFields.indexOf(currentTextField) else {
            return
        }
        
        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        textFields[prevIndex].becomeFirstResponder()
    }
    
    @objc private func nextButtonTapped(button: UIBarButtonItem) {
        guard let currentTextField = currentTextField, let index = textFields.indexOf(currentTextField) else {
            return
        }
        
        let nextIndex = index + 1
        guard nextIndex < textFields.count else { return }
        textFields[nextIndex].becomeFirstResponder()
    }
}
