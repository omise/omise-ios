import UIKit

@objc(OMSAtomeFormViewController)
// swiftlint:disable:next attributes
class AtomeFormViewController: UIViewController, PaymentSourceChooser, PaymentChooserUI, PaymentFormUIController {
    
    var flowSession: PaymentCreatorFlowSession?
    
    private var client: Client?
    
    private var isInputDataValid: Bool {
        return formFields.reduce(into: true) { (valid, field) in
            valid = valid && field.isValid
        }

    }
    
    @IBInspectable var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    @IBInspectable var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    var currentEditingTextField: OmiseTextField?
    
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet private var nameTextField: OmiseTextField!
    @IBOutlet private var emailTextField: OmiseTextField!
    @IBOutlet private var phoneNumberTextField: OmiseTextField!
    @IBOutlet private var shippingStreetTextField: OmiseTextField!
    @IBOutlet private var shippingCityTextField: OmiseTextField!
    @IBOutlet private var shippingCountryCodeTextField: OmiseTextField!
    @IBOutlet private var shippingPostalCodeTextField: OmiseTextField!
    @IBOutlet private var submitButton: MainActionButton!
    @IBOutlet private var requestingIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private var phoneNumberErrorLabel: UILabel!
    @IBOutlet private var emailErrorLabel: UILabel!
    @IBOutlet private var shippingStreetErrorLabel: UILabel!
    @IBOutlet private var shippingCityErrorLabel: UILabel!
    @IBOutlet private var shippingCountryErrorLabel: UILabel!
    @IBOutlet private var shippingPostalCodeErrorLabel: UILabel!
    
    @IBOutlet var formLabels: [UILabel]!
    @IBOutlet var formFields: [OmiseTextField]!
    
    @IBOutlet var formFieldsAccessoryView: UIToolbar!
    @IBOutlet var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var gotoNextFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneEditingBarButtonItem: UIBarButtonItem!
    
    // need to refactor loadView, removing super results in crash
    // swiftlint:disable prohibited_super_call
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .background
        formFieldsAccessoryView.barTintColor = .formAccessoryBarTintColor
        
        submitButton.defaultBackgroundColor = .omise
        submitButton.disabledBackgroundColor = .line
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyPrimaryColor()
        applySecondaryColor()
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
        
        phoneNumberTextField.addTarget(self, action: #selector(validateForm), for: .editingDidEndOnExit)
        emailTextField.addTarget(self, action: #selector(validateForm), for: .editingDidEnd)
        shippingStreetTextField.addTarget(self, action: #selector(validateForm), for: .editingDidEnd)
        shippingCountryCodeTextField.addTarget(self, action: #selector(validateForm), for: .editingDidEnd)
        shippingCityTextField.addTarget(self, action: #selector(validateForm), for: .editingDidEnd)
        shippingPostalCodeTextField.addTarget(self, action: #selector(validateForm), for: .editingDidEnd)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: NotificationKeyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NotificationKeyboardWillHideFrameNotification,
            object: nil
        )

        phoneNumberTextField.validator = try? NSRegularExpression(pattern: "^(\\+\\d{2}|0)\\d{9}$", options: [])
        emailTextField.validator = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: [])
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

    fileprivate func associatedErrorLabelOf(_ textField: OmiseTextField) -> UILabel? {
        switch textField {
        case phoneNumberTextField:
            return phoneNumberErrorLabel
        case emailTextField:
            return emailErrorLabel
        case shippingStreetTextField:
            return shippingStreetErrorLabel
        case shippingCityTextField:
            return shippingCityErrorLabel
        case shippingCountryCodeTextField:
            return shippingCountryErrorLabel
        case shippingPostalCodeTextField:
            return shippingPostalCodeErrorLabel
        default:
            return nil
        }
    }
    
    @objc func validateForm(_ textField: OmiseTextField) {
        validateField(textField)
        validateFieldData(textField)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let frameEnd = notification.userInfo?[NotificationKeyboardFrameEndUserInfoKey] as? CGRect,
            let frameStart = notification.userInfo?[NotificationKeyboardFrameBeginUserInfoKey] as? CGRect,
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
}

private extension AtomeFormViewController {
    @IBAction func submitForm(_ sender: AnyObject) {
        guard let name = nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        guard let email = emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        guard let phone = phoneNumberTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        guard let street = shippingStreetTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        guard let city = shippingCityTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        guard let country = shippingCountryCodeTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        guard let postcode = shippingPostalCodeTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }

        let atomeInfo = PaymentInformation.Atome(phoneNumber: phone,
                                                 shippingStreet: street,
                                                 shippingCity: city,
                                                 shippingCountryCode: country,
                                                 shippingPostalCode: postcode,
                                                 name: name,
                                                 email: email)
        requestingIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        view.tintAdjustmentMode = .dimmed
        submitButton.isEnabled = false
        flowSession?.requestCreateSource(.atome(atomeInfo)) { _ in
            self.requestingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.view.tintAdjustmentMode = .automatic
            self.submitButton.isEnabled = true
        }
    }

    @IBAction func validateFieldData(_ textField: OmiseTextField) {
        submitButton.isEnabled = isInputDataValid
    }

    @IBAction func validateTextFieldDataOf(_ sender: OmiseTextField) {
        let duration = TimeInterval(NavigationControllerHideShowBarDuration)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
            self.validateField(sender)
        }
        sender.borderColor = currentSecondaryColor
    }

    @IBAction func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
        if let errorLabel = associatedErrorLabelOf(sender) {
            let duration = TimeInterval(NavigationControllerHideShowBarDuration)
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
                errorLabel.alpha = 0.0
            }
        }

        updateInputAccessoryViewWithFirstResponder(sender)
        sender.borderColor = view.tintColor
    }

    @IBAction func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }

    // swiftlint:disable:next function_body_length
    func validateField(_ textField: OmiseTextField) {
        guard let errorLabel = associatedErrorLabelOf(textField) else {
            return
        }
        do {
            try textField.validate()
            errorLabel.alpha = 0.0
        } catch {
            switch (error, textField) {
            case (OmiseTextFieldValidationError.invalidData, phoneNumberTextField):
                errorLabel.text = NSLocalizedString(
                    "atome-info-form.phone-number-field.invalid-data.error.text",
                    tableName: "Error",
                    bundle: .module,
                    value: "Please enter valid phone number",
                    comment: "An error text in the Atome information input displayed when the phone number is invalid"
                )
            case (OmiseTextFieldValidationError.invalidData, emailTextField):
                errorLabel.text = NSLocalizedString(
                    "atome-info-form.email-name-field.invalid-data.error.text",
                    tableName: "Error",
                    bundle: .module,
                    value: "Email is invalid",
                    comment: "An error text in the Atome information input displayed when the email is invalid"
                )
            case (OmiseTextFieldValidationError.emptyText, shippingStreetTextField):
                errorLabel.text = NSLocalizedString(
                    "atome-info-form.shipping-street-field.empty-text.error.text",
                    tableName: "Error",
                    bundle: .module,
                    value: "Shipping street is required",
                    comment: "An error text in the Atome information input displayed when the shipping street is empty"
                )
            case (OmiseTextFieldValidationError.emptyText, shippingCityTextField):
                errorLabel.text = NSLocalizedString(
                    "atome-info-form.shipping-city-field.empty-text.error.text",
                    tableName: "Error",
                    bundle: .module,
                    value: "Shipping city is required",
                    comment: "An error text in the Atome information input displayed when the shipping city is empty"
                )
            case (OmiseTextFieldValidationError.emptyText, shippingCountryCodeTextField):
                errorLabel.text = NSLocalizedString(
                    "atome-info-form.shipping-country-code-field.empty-text.error.text",
                    tableName: "Error",
                    bundle: .module,
                    value: "Shipping country is required",
                    comment: "An error text in the Atome information input displayed when the shipping country is empty"
                )
            case (OmiseTextFieldValidationError.emptyText, shippingPostalCodeTextField):
                errorLabel.text = NSLocalizedString(
                    "atome-info-form.shipping-postal_code-field.empty-text.error.text",
                    tableName: "Error",
                    bundle: .module,
                    value: "Shipping postal code is required",
                    comment: "An error text in the Atome information input displayed when the shipping postal code is empty"
                )
            case (_, phoneNumberTextField):
                errorLabel.text = error.localizedDescription
            case (_, shippingStreetTextField):
                errorLabel.text = error.localizedDescription
            case (_, shippingCityTextField):
                errorLabel.text = error.localizedDescription
            case (_, shippingCountryCodeTextField):
                errorLabel.text = error.localizedDescription
            case (_, shippingPostalCodeTextField):
                errorLabel.text = error.localizedDescription
            default:
                errorLabel.text = "-"
            }
            errorLabel.alpha = errorLabel.text != "-" ? 1.0 : 0.0
        }
    }
}
