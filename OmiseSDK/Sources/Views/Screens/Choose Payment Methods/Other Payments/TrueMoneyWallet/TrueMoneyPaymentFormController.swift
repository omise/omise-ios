import UIKit

class TrueMoneyPaymentFormController: UIViewController, PaymentFormUIController {
    weak var delegate: SelectSourcePaymentDelegate?

    private var client: ClientProtocol?
    
    private var isInputDataValid: Bool {
        return formFields.allSatisfy { $0.isValid }
    }

    var currentEditingTextField: OmiseTextField?
    
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet private var pleaseInputLabel: UILabel!
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var phoneNumberTextField: OmiseTextField!
    @IBOutlet private var submitButton: MainActionButton!
    @IBOutlet private var requestingIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private var errorLabel: UILabel!

    lazy var formLabels: [UILabel]! = {
        [phoneNumberLabel]
    }()

    lazy var formFields: [OmiseTextField]! = {
        [phoneNumberTextField]
    }()

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

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        navigationItem.backBarButtonItem = .empty
        
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
        
        if #unavailable(iOS 11) {
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
        
        phoneNumberTextField.validator = try? NSRegularExpression(pattern: "\\d{10,11}\\s?", options: [])
        setupTextFieldHandlers()

        contentView.adjustContentInsetOnKeyboardAppear()

        pleaseInputLabel.text = localized("TrueMoneyWallet.label.pleaseInput.text")
        phoneNumberLabel.text = localized("TrueMoneyWallet.field.phoneNumber")
        submitButton.setTitle(localized("TrueMoneyWallet.nextButton.title"), for: .normal)
    }

    private func setupTextFieldHandlers() {
        self.formFields.forEach { field in
            setupTextField(field)
        }
    }

    private func setupTextField(_ field: OmiseTextField) {
        field.addTarget(self, action: #selector(validateFieldData), for: .editingChanged)
        field.addTarget(self, action: #selector(updateInputAccessoryViewFor), for: .editingDidBegin)
        field.addTarget(self, action: #selector(validateTextFieldDataOf), for: .editingDidEnd)
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

    @IBAction private func submitForm(_ sender: AnyObject) {
        guard let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }
        
        let paymentInformation = Source.Payment.TrueMoneyWallet(phoneNumber: phoneNumber)
        requestingIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        view.tintAdjustmentMode = .dimmed
        submitButton.isEnabled = false
        delegate?.didSelectSourcePayment(.trueMoneyWallet(paymentInformation)) { [weak self] in
            guard let self = self else { return }
            self.requestingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.view.tintAdjustmentMode = .automatic
            self.submitButton.isEnabled = true
        }
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
    
    @IBAction private func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
        let duration = TimeInterval(UINavigationController.hideShowBarDuration)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
            self.errorLabel.alpha = 0.0
        }
        
        updateInputAccessoryViewWithFirstResponder(sender)
        sender.borderColor = view.tintColor
    }
    
    @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }
    
    private func validateField(_ textField: OmiseTextField) {
        do {
            try textField.validate()
            errorLabel.alpha = 0.0
        } catch {
            switch error {
            case OmiseTextFieldValidationError.emptyText:
                errorLabel.text = "-" // We need to set the error label some string in order to have it retains its height
                
            case OmiseTextFieldValidationError.invalidData:
                errorLabel.text = NSLocalizedString(
                    "truemoney-form.phone-number-field.invalid-data.error.text",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: "Phone number is invalid",
                    comment: "An error text in the TrueMoney form displayed when the phone number is invalid"
                )
                
            default:
                errorLabel.text = error.localizedDescription
            }
            errorLabel.alpha = errorLabel.text != "-" ? 1.0 : 0.0
        }
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
    
}
