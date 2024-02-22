import UIKit

class EContextInformationInputViewController: UIViewController, PaymentSourceChooser, PaymentFormUIController {
    var flowSession: PaymentCreatorFlowSession?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    var currentEditingTextField: OmiseTextField?
    
    var isInputDataValid: Bool {
        return formFields.allSatisfy { $0.isValid }
    }
    
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet private var fullNameTextField: OmiseTextField!
    @IBOutlet private var emailTextField: OmiseTextField!
    @IBOutlet private var phoneNumberTextField: OmiseTextField!
    @IBOutlet private var submitButton: MainActionButton!
    @IBOutlet private var requestingIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private var fullNameErrorLabel: UILabel!
    @IBOutlet private var emailErrorLabel: UILabel!
    @IBOutlet private var phoneNumberErrorLabel: UILabel!
    
    @IBOutlet var formLabels: [UILabel]!
    @IBOutlet var formFields: [OmiseTextField]!
    @IBOutlet var errorLabels: [UILabel]!
    @IBOutlet var formFieldsAccessoryView: UIToolbar!
    @IBOutlet var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var gotoNextFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneEditingBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        formFieldsAccessoryView.barTintColor = .formAccessoryBarTintColor

        submitButton.defaultBackgroundColor = .omise
        submitButton.disabledBackgroundColor = .line

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        formFields.forEach {
            $0.inputAccessoryView = formFieldsAccessoryView
        }
        
        formFields.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        formLabels.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        submitButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        if  #unavailable(iOS 11) {
            // We'll leave the adjusting scroll view insets job for iOS 11 and later to the layoutMargins + safeAreaInsets here
            automaticallyAdjustsScrollViewInsets = true
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        fullNameTextField.validator = try? NSRegularExpression(pattern: "\\A[\\w\\s]{1,10}\\s?\\z", options: [])
        emailTextField.validator = try? NSRegularExpression(pattern: "\\A[\\w\\-\\.]+@[\\w\\-\\.]+\\s?\\z", options: [])
        phoneNumberTextField.validator = try? NSRegularExpression(pattern: "\\d{10,11}\\s?", options: [])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #unavailable(iOS 11) {
            // There's a bug in iOS 10 and earlier which the text field's intrinsicContentSize is returned the value
            // that doesn't take the result of textRect(forBounds:) method into an account for the initial value
            // So we need to invalidate the intrinsic content size here to ask those text fields to calculate their
            // intrinsic content size again

            formFields.forEach {
                $0.invalidateIntrinsicContentSize()
            }
        }
    }
    
    @IBAction private func submitEContextForm(_ sender: AnyObject) {
        guard let fullname = fullNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces),
            let email = emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces),
            let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
                return
        }
        
        let eContextInformation = Source.Payment.EContext(name: fullname, email: email, phoneNumber: phoneNumber)
        requestingIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        view.tintAdjustmentMode = .dimmed
        submitButton.isEnabled = false
        flowSession?.requestCreateSource(Source.Payment.eContext(eContextInformation)) { _ in
            self.requestingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.view.tintAdjustmentMode = .automatic
            self.submitButton.isEnabled = true
        }
    }
    
    @IBAction private func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
        if let errorLabel = associatedErrorLabelOf(sender) {
            let duration = TimeInterval(UINavigationController.hideShowBarDuration)
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
                errorLabel.alpha = 0.0
            }
        }
        
        updateInputAccessoryViewWithFirstResponder(sender)
        sender.borderColor = view.tintColor
    }
    
    @IBAction private func gotoPreviousField(_ button: UIBarButtonItem) {
        gotoPreviousField()
    }
    
    @IBAction private func gotoNextField(_ sender: AnyObject) {
        gotoNextField()
    }
    
    @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }
    
    @IBAction private func validateFieldData(_ textField: OmiseTextField) {
        submitButton.isEnabled = isInputDataValid
    }
    
    @IBAction private func validateTextFieldDataOf(_ sender: OmiseTextField) {
        let duration = TimeInterval(UINavigationController.hideShowBarDuration)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
            self.validateField(sender)
        }
        sender.borderColor = UIColor.omiseSecondary
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let frameStart = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            frameEnd != frameStart else {
                return
        }
        
        let intersectedFrame = contentView.convert(frameEnd, from: nil)
        
        contentView.contentInset.bottom = intersectedFrame.height
        let bottomScrollIndicatorInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomScrollIndicatorInset = intersectedFrame.height - contentView.safeAreaInsets.bottom
        } else {
            bottomScrollIndicatorInset = intersectedFrame.height
        }
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        contentView.contentInset.bottom = 0.0
        contentView.scrollIndicatorInsets.bottom = 0.0
    }
    
    fileprivate func associatedErrorLabelOf(_ textField: OmiseTextField) -> UILabel? {
        switch textField {
        case fullNameTextField:
            return fullNameErrorLabel
        case emailTextField:
            return emailErrorLabel
        case phoneNumberTextField:
            return phoneNumberErrorLabel
        default:
            return nil
        }
    }
    
    private func validateField(_ textField: OmiseTextField) {
        guard let errorLabel = associatedErrorLabelOf(textField) else {
            return
        }
        do {
            try textField.validate()
            errorLabel.alpha = 0.0
        } catch {
            switch (error, textField) {
            case (OmiseTextFieldValidationError.emptyText, _):
                errorLabel.text = "-" // We need to set the error label some string in order to have it retains its height
                
            case (OmiseTextFieldValidationError.invalidData, fullNameTextField):
                errorLabel.text = NSLocalizedString(
                    "econtext-info-form.full-name-field.invalid-data.error.text",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: "Customer name is invalid",
                    comment: "An error text in the E-Context information input displayed when the customer name is invalid"
                )
            case (OmiseTextFieldValidationError.invalidData, emailTextField):
                errorLabel.text = NSLocalizedString(
                    "econtext-info-form.email-name-field.invalid-data.error.text",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: "Email is invalid",
                    comment: "An error text in the E-Context information input displayed when the email is invalid"
                )
            case (OmiseTextFieldValidationError.invalidData, phoneNumberTextField):
                errorLabel.text = NSLocalizedString(
                    "econtext-info-form.phone-number-field.invalid-data.error.text",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: "Phone number is invalid",
                    comment: "An error text in the E-Context information input displayed when the phone number is invalid"
                )
                
            case (_, fullNameTextField):
                errorLabel.text = error.localizedDescription
            case (_, emailTextField):
                errorLabel.text = error.localizedDescription
            case (_, phoneNumberTextField):
                errorLabel.text = error.localizedDescription
            default:
                errorLabel.text = "-"
            }
            errorLabel.alpha = errorLabel.text != "-" ? 1.0 : 0.0
        }
    }
}
