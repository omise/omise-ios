import Foundation

/// An input accessory view that provides next and previous buttons for moving between form fields.
@objc(OMSFormAccessoryView) public class OmiseFormAccessoryView: UIToolbar {
    private var textFields = [UITextField]() {
        willSet {
            textFields.forEach { (textField) in
                textField.removeTarget(self, action: #selector(textFieldDidBeginEditing), for: UIControlEvents.editingDidBegin)
            }
        }
        didSet {
            textFields.forEach { (textField) in
                textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: UIControlEvents.editingDidBegin)
                textField.inputAccessoryView = self
            }
        }
    }
    private var currentTextField: UITextField?
    private var previousButton = UIBarButtonItem()
    private var nextButton = UIBarButtonItem()
    
    public init() {
        super.init(frame: CGRect.zero)
        self.sizeToFit()
        
        let bundle = Bundle(for: OmiseFormAccessoryView.self)
        
        previousButton.image = UIImage(named: "backBarButton", in: bundle, compatibleWith: nil)
        previousButton.style = .plain
        previousButton.width = 30
        previousButton.target = self
        previousButton.action = #selector(previousButtonTapped)
        
        nextButton.image = UIImage(named: "nextBarButton", in: bundle, compatibleWith: nil)
        nextButton.style = .plain
        nextButton.width = 30
        nextButton.target = self
        nextButton.action = #selector(nextButtonTapped)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Attach this accessory view to a set of text fields and view controller.
     - parameter textFields: Array of `UITextField` instances to attach to. Text fields
         navigation order will be defined by the order in this array.
     - parameter viewController: A `UIViewController` that houses the supplied text fields.
         The view controller's view will be used as target for `endEditing` calls when
         the `Done` button is tapped.
     */
    @objc public func attach(to textFields: [UITextField], in viewController: UIViewController) {
        self.textFields = textFields
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: viewController.view, action: #selector(UIView.endEditing))
        
        let items = [previousButton, nextButton, spacer, doneButton]
        self.setItems(items, animated: false)
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        previousButton.isEnabled = textField != textFields.first
        nextButton.isEnabled = textField != textFields.last
    }
    
    @objc private func previousButtonTapped(_ button: UIBarButtonItem) {
        guard let currentTextField = currentTextField, let index = textFields.index(of: currentTextField) else {
            return
        }
        
        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        textFields[prevIndex].becomeFirstResponder()
    }
    
    @objc private func nextButtonTapped(_ button: UIBarButtonItem) {
        guard let currentTextField = currentTextField, let index = textFields.index(of: currentTextField) else {
            return
        }
        
        let nextIndex = index + 1
        guard nextIndex < textFields.count else { return }
        textFields[nextIndex].becomeFirstResponder()
    }
}
