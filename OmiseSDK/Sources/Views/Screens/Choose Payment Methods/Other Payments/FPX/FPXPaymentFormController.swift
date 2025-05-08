import UIKit

class FPXPaymentFormController: BaseFormViewController {
    // MARK: - UI Elements
    private lazy var imgFPX: UIImageView = {
        UIImageView(image: UIImage(named: "FPX_Big", in: .omiseSDK, compatibleWith: .none))
            .contentMode(.scaleAspectFit)
    }()
    
    private lazy var pleaseInputLabel: UILabel = {
        let label = UILabel()
        label.text(localized("fpx.label.pleaseInput.text"))
        configureBody(label)
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text(localized("fpx.field.email"))
        configure(label)
        return label
    }()
    
    private lazy var emailTextField: OmiseTextField = {
        let tf = OmiseTextField()
        tf.validator = try? NSRegularExpression(pattern: "\\A[\\w.+-]+@[a-z\\d.-]+\\.[a-z]{2,}\\z",
                                                options: [.caseInsensitive])
        tf.setAccessibilityID(id: "fpx.emailTextField")
        tf.keyboardType = .emailAddress
        configure(tf)
        return tf
    }()
    
    private lazy var emailErrorLabel: UILabel = {
        let label = UILabel()
        label.text("-").setAccessibilityID(id: "fpx.emailError")
        configureError(label)
        return label
    }()
    
    private lazy var submitButton: MainActionButton = {
        let button = MainActionButton()
        button.setTitle(localized("fpx.nextButton.title"), for: .normal)
        button.font(.preferredFont(forTextStyle: .headline))
        button.defaultBackgroundColor = .omise
        button.disabledBackgroundColor = .line
        button.cornerRadius = 4
        button.isEnabled = false
        button.addTarget(self, action: #selector(submitForm(_:)), for: .touchUpInside)
        button.setAccessibilityID(id: "fpx.submitButton")
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
    
    let viewModel: FPXPaymentFormViewModelProtocol
    
    // MARK: - Initialization
    init(viewModel: FPXPaymentFormViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .omiseSDK)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add the content view (inherited from BaseFormViewController)
        view.addSubviewAndFit(contentView)
        
        setupUI()
        setupTextFieldHandlers()
        setupHandlers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppear() // reset state
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubviewAndFit(formStack, vertical: padding, horizontal: padding)
        
        formStack.constrainWidth(equalTo: contentView, constant: -(padding * 2))
        formStack.addArrangedSubviews([
            getStackViewGroup(for: [imgFPX, pleaseInputLabel]),
            getStackViewGroup(for: [emailLabel, emailTextField, emailErrorLabel]),
            submitButton
        ])
        
        contentView.addSubview(requestingIndicatorView)
        requestingIndicatorView.setToCenter(of: submitButton)
        
        // Tell the base controller which fields to handle.
        formFields = [emailTextField]
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
    @objc func submitForm(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        viewModel.input.startPayment(email: email)
    }
    
    func validateField(_ textField: OmiseTextField) {
        do {
            try textField.validate()
            emailErrorLabel.alpha(0.0)
        } catch {
            switch error {
            case OmiseTextFieldValidationError.emptyText:
                emailErrorLabel.text("-")
            case OmiseTextFieldValidationError.invalidData:
                emailErrorLabel.text(viewModel.output.emailError)
            default:
                emailErrorLabel.text(error.localizedDescription)
            }
            emailErrorLabel.alpha(emailErrorLabel.text != "-" ? 1.0 : 0.0)
        }
    }
    
}

// MARK: - TextFields Helper
extension FPXPaymentFormController {
    func setupTextFieldHandlers() {
        emailTextField.addTarget(self,
                                 action: #selector(textFieldEditingDidBegin(_:)),
                                 for: .editingDidBegin)
        emailTextField.addTarget(self,
                                 action: #selector(textFieldEditingDidEndOnExit(_:)),
                                 for: .editingDidEndOnExit)
        emailTextField.addTarget(self,
                                 action: #selector(validateFieldData(_:)),
                                 for: .editingChanged)
        emailTextField.addTarget(self,
                                 action: #selector(validateTextFieldDataOf(_:)),
                                 for: .editingDidEnd)
        
        validateFieldData(emailTextField)
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
            self?.emailErrorLabel.alpha = 0.0
        }
        updateNavigationButtons(for: textField)
    }
    
    @objc func textFieldEditingDidEndOnExit(_ textField: OmiseTextField) {
        gotoNextField()
    }
    
    @objc func validateFieldData(_ textField: OmiseTextField) {
        submitButton.isEnabled = formFields.allSatisfy { $0.isValid || ($0.text ?? "").isEmpty }
    }
    
    @objc func validateTextFieldDataOf(_ textField: OmiseTextField) {
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
            self.validateField(textField)
        }
        textField.borderColor = .omiseSecondary
        validateFieldData(textField)
    }
}
