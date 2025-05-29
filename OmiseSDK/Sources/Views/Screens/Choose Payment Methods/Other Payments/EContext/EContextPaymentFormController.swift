import UIKit
import Foundation

class EContextPaymentFormController: BaseFormViewController {
    // MARK: - UI Elements
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.text(localized("EContext.field.fullName"))
        configure(label)
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text(localized("EContext.field.email"))
        configure(label)
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text(localized("EContext.field.phone"))
        configure(label)
        return label
    }()
    
    private lazy var fullNameTextField: OmiseTextField = {
        let tf = OmiseTextField()
        tf.validator = try? NSRegularExpression(pattern: "\\A[\\w\\s]{1,10}\\s?\\z", options: [])
        tf.setAccessibilityID("EContextForm.nameTextField")
        configure(tf)
        return tf
    }()
    
    private lazy var emailTextField: OmiseTextField = {
        let tf = OmiseTextField()
        tf.validator = try? NSRegularExpression(pattern: "\\A[\\w\\-\\.]+@[\\w\\-\\.]+\\s?\\z", options: [])
        tf.setAccessibilityID("EContextForm.emailTextField")
        configure(tf)
        return tf
    }()
    
    private lazy var phoneNumberTextField: OmiseTextField = {
        let tf = OmiseTextField()
        tf.validator = try? NSRegularExpression(pattern: "\\d{10,11}\\s?", options: [])
        tf.setAccessibilityID("EContextForm.phoneTextField")
        tf.keyboardType = .phonePad
        configure(tf)
        return tf
    }()
    
    // Error Labels
    private lazy var fullNameErrorLabel: UILabel = {
        let label = UILabel()
        label.text("-").setAccessibilityID("EContextForm.nameError")
        configureError(label)
        return label
    }()
    
    private lazy var emailErrorLabel: UILabel = {
        let label = UILabel()
        label.text("-").setAccessibilityID("EContextForm.emailError")
        configureError(label)
        return label
    }()
    
    private lazy var phoneNumberErrorLabel: UILabel = {
        let label = UILabel()
        label.text("-").setAccessibilityID("EContextForm.phoneError")
        configureError(label)
        return label
    }()
    
    private lazy var submitButton: MainActionButton = {
        let button = MainActionButton()
        button.setTitle(localized("EContext.nextButton.title"), for: .normal)
        button.font(.preferredFont(forTextStyle: .headline))
        button.defaultBackgroundColor = .omise
        button.disabledBackgroundColor = .line
        button.cornerRadius = 4
        button.isEnabled = false
        button.addTarget(self, action: #selector(submitEContextForm(_:)), for: .touchUpInside)
        button.setAccessibilityID("EContextForm.submitButton")
            .translatesAutoresizingMaskIntoConstraints(false)
        return button
    }()
    
    private lazy var formStack: UIStackView = {
        let stack = UIStackView()
        stack.axis(.vertical)
            .alignment(.fill)
            .spacing(spacing)
            .translatesAutoresizingMaskIntoConstraints(false)
        return stack
    }()
    
    let viewModel: EContextPaymentFormViewModelProtocol
    
    // MARK: - Initialization
    init(viewModel: EContextPaymentFormViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .omiseSDK)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add the content view (inherited from BaseFormViewController)
        view.addSubviewAndFit(contentView)
        
        setupUI()
        setupTextFieldHandlers()
        setupHandlers()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubviewAndFit(formStack, vertical: padding, horizontal: padding)
        formStack.constrainWidth(equalTo: contentView, constant: -(padding * 2))
        
        // Add rows: Label, TextField, and Error label for each form element.
        formStack.addArrangedSubviews([
            getStackViewGroup(for: [fullNameLabel, fullNameTextField, fullNameErrorLabel]),
            getStackViewGroup(for: [emailLabel, emailTextField, emailErrorLabel]),
            getStackViewGroup(for: [phoneNumberLabel, phoneNumberTextField, phoneNumberErrorLabel]),
            submitButton
        ])
        
        contentView.addSubview(requestingIndicatorView)
        requestingIndicatorView.setToCenter(of: submitButton)
        
        // Tell the base controller which fields to handle.
        formFields = [fullNameTextField, emailTextField, phoneNumberTextField]
        contentView.adjustContentInsetOnKeyboardAppear()
    }
    
    private func setupHandlers() {
        viewModel.input.set { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                self.requestingIndicatorView.startAnimating()
                self.view.isUserInteractionEnabled = false
                self.view.tintAdjustmentMode = .dimmed
                self.submitButton.isEnabled = false
            } else {
                self.requestingIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.view.tintAdjustmentMode = .automatic
                self.submitButton.isEnabled = true
            }
        }
    }
    
    private func getStackViewGroup(for views: [UIView]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis(.vertical)
            .alignment(.fill)
            .spacing(minSpacing)
            .translatesAutoresizingMaskIntoConstraints(false)
            .addArrangedSubviews(views)
        return stackView
    }
    
    // MARK: - Form Submission
    @objc func submitEContextForm(_ sender: UIButton) {
        guard let fullname = fullNameTextField.text?.trimmingCharacters(in: .whitespaces),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
              let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        viewModel.input.startPayment(name: fullname, email: email, phone: phoneNumber)
    }
    
    func validateField(_ textField: OmiseTextField) {
        guard let errorLabel = associatedErrorLabel(of: textField) else { return }
        do {
            try textField.validate()
            errorLabel.alpha(0.0)
        } catch {
            switch (error, textField) {
            case (OmiseTextFieldValidationError.emptyText, _):
                errorLabel.text("-")
            case (OmiseTextFieldValidationError.invalidData, fullNameTextField):
                errorLabel.text(viewModel.output.nameError)
            case (OmiseTextFieldValidationError.invalidData, emailTextField):
                errorLabel.text(viewModel.output.emailError)
            case (OmiseTextFieldValidationError.invalidData, phoneNumberTextField):
                errorLabel.text(viewModel.output.phoneError)
            default:
                errorLabel.text(error.localizedDescription)
            }
            errorLabel.alpha(errorLabel.text != "-" ? 1.0 : 0.0)
        }
    }
}

// MARK: - TextFields Helper
private extension EContextPaymentFormController {
    func setupTextFieldHandlers() {
        for field in formFields {
            field.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
            field.addTarget(self, action: #selector(textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
            field.addTarget(self, action: #selector(validateFieldData(_:)), for: .editingChanged)
            field.addTarget(self, action: #selector(validateTextFieldDataOf(_:)), for: .editingDidEnd)
        }
    }
    
    @objc func textFieldEditingDidBegin(_ textField: OmiseTextField) {
        let duration = TimeInterval(UINavigationController.hideShowBarDuration)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [
                        .curveEaseInOut,
                        .allowUserInteraction,
                        .beginFromCurrentState,
                        .layoutSubviews
                       ]
        ) { [weak self] in
            if let errorLabel = self?.associatedErrorLabel(of: textField) {
                errorLabel.alpha = 0.0
            }
        }
        updateNavigationButtons(for: textField)
    }
    
    @objc func textFieldEditingDidEndOnExit(_ textField: OmiseTextField) {
        gotoNextField()
    }
    
    @objc func validateFieldData(_ textField: OmiseTextField) {
        submitButton.isEnabled = formFields.allSatisfy { $0.isValid }
    }
    
    @objc func validateTextFieldDataOf(_ textField: OmiseTextField) {
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
            self.validateField(textField)
        }
        textField.borderColor = .omiseSecondary
    }
    
    func associatedErrorLabel(of textField: OmiseTextField) -> UILabel? {
        switch textField {
        case fullNameTextField: return fullNameErrorLabel
        case emailTextField: return emailErrorLabel
        case phoneNumberTextField: return phoneNumberErrorLabel
        default: return nil
        }
    }
}
