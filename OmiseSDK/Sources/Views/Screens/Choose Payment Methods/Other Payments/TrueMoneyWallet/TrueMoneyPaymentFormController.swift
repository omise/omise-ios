import UIKit

class TrueMoneyPaymentFormController: BaseFormViewController {
    // MARK: - UI Elements
    private lazy var imgTrueMoney: UIImageView = {
        UIImageView(image: UIImage(omise: "TrueMoney_Big"))
            .contentMode(.scaleAspectFit)
    }()
    
    private lazy var pleaseInputLabel: UILabel = {
        let label = UILabel()
        label.text(localized("TrueMoneyWallet.label.pleaseInput.text"))
        configureBody(label)
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text(localized("TrueMoneyWallet.field.phoneNumber"))
        configure(label)
        return label
    }()
    
    private lazy var phoneNumberTextField: OmiseTextField = {
        let tf = OmiseTextField()
        tf.validator = try? NSRegularExpression(pattern: "\\d{10,11}\\s?", options: [])
        tf.setAccessibilityID("TrueMoneyPaymentForm.phoneTextField")
        tf.keyboardType = .phonePad
        configure(tf)
        return tf
    }()
    
    private lazy var phoneNumberErrorLabel: UILabel = {
        let label = UILabel()
        label.text("-").setAccessibilityID("TrueMoneyPaymentForm.phoneError")
        configureError(label)
        return label
    }()
    
    private lazy var submitButton: MainActionButton = {
        let button = MainActionButton()
        button.setTitle(localized("TrueMoneyWallet.nextButton.title"), for: .normal)
        button.font(.preferredFont(forTextStyle: .headline))
        button.defaultBackgroundColor = .omise
        button.disabledBackgroundColor = .line
        button.cornerRadius = 4
        button.isEnabled = false
        button.addTarget(self, action: #selector(submitTrueMoneyForm(_:)), for: .touchUpInside)
        button.setAccessibilityID("TrueMoneyPaymentForm.submitButton")
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
    
    let viewModel: TrueMoneyPaymentFormProtocol
    
    // MARK: - Initialization
    init(viewModel: TrueMoneyPaymentFormProtocol) {
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
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubviewAndFit(formStack, vertical: padding, horizontal: padding)
        
        formStack.constrainWidth(equalTo: contentView, constant: -(padding * 2))
        formStack.addArrangedSubviews([
            getStackViewGroup(for: [imgTrueMoney, pleaseInputLabel]),
            getStackViewGroup(for: [phoneNumberLabel, phoneNumberTextField, phoneNumberErrorLabel]),
            submitButton
        ])
        
        contentView.addSubview(requestingIndicatorView)
        requestingIndicatorView.setToCenter(of: submitButton)
        
        // Tell the base controller which fields to handle.
        formFields = [phoneNumberTextField]
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
    @objc func submitTrueMoneyForm(_ sender: UIButton) {
        guard let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        viewModel.input.startPayment(for: phoneNumber)
    }
    
    func validateField(_ textField: OmiseTextField) {
        do {
            try textField.validate()
            phoneNumberErrorLabel.alpha(0.0)
        } catch {
            switch (error, textField) {
            case (OmiseTextFieldValidationError.emptyText, _):
                phoneNumberErrorLabel.text("-")
            case (OmiseTextFieldValidationError.invalidData, phoneNumberTextField):
                phoneNumberErrorLabel.text(viewModel.output.phoneError)
            default:
                phoneNumberErrorLabel.text(error.localizedDescription)
            }
            phoneNumberErrorLabel.alpha(phoneNumberErrorLabel.text != "-" ? 1.0 : 0.0)
        }
    }
    
}

// MARK: - TextFields Helper
extension TrueMoneyPaymentFormController {
    func setupTextFieldHandlers() {
        phoneNumberTextField.addTarget(self,
                                       action: #selector(textFieldEditingDidBegin(_:)),
                                       for: .editingDidBegin)
        phoneNumberTextField.addTarget(self,
                                       action: #selector(textFieldEditingDidEndOnExit(_:)),
                                       for: .editingDidEndOnExit)
        phoneNumberTextField.addTarget(self,
                                       action: #selector(validateFieldData(_:)),
                                       for: .editingChanged)
        phoneNumberTextField.addTarget(self,
                                       action: #selector(validateTextFieldDataOf(_:)),
                                       for: .editingDidEnd)
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
            self?.phoneNumberErrorLabel.alpha = 0.0
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
}
