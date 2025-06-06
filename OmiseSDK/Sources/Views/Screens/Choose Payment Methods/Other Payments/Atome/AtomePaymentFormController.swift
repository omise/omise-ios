import Foundation
import UIKit

class AtomePaymentInputsFormController: PaymentFormController {
    typealias ViewModel = AtomePaymentFormViewModelProtocol
    typealias ViewContext = AtomePaymentFormViewContext
    typealias Field = ViewContext.Field
    
    lazy var shippingAddressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = style.sectionTitleColor
        label.font = .preferredFont(forTextStyle: .callout)
        label.text = "Atome.shippingAddress".localized()
        return label
    }()
    
    lazy var billingAddressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = style.sectionTitleColor
        label.font = .preferredFont(forTextStyle: .callout)
        label.text = "Atome.billingAddress".localized()
        return label
    }()
    
    lazy var billingAddressCheckbox: OmiseCheckbox = {
        let cb = OmiseCheckbox(
            text: "Atome.field.billing.the.same".localized(),
            isChecked: true
        )
        cb.translatesAutoresizingMaskIntoConstraints(false)
        cb.onToggle = { [weak self] isSelected in
            guard let self = self else { return }
            self.handleBillingAddress(shouldHide: isSelected)
            self.updateSubmitButtonState()
        }
        return cb
    }()
    
    var viewModel: ViewModel
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .omiseSDK)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewModel)
        onSubmitButtonTappedClosure = onSubmitButtonHandler
    }
    
    override func updateSubmitButtonState() {
        let isEnabled = viewModel.isSubmitButtonEnabled(makeViewContext())
        self.submitButton.isEnabled = isEnabled
        isSubmitButtonEnabled = isEnabled
    }
}

private extension AtomePaymentInputsFormController {
    
    func onSubmitButtonHandler() {
        let currentContext = makeViewContext()
        guard viewModel.isSubmitButtonEnabled(currentContext) else {
            return
        }
        
        viewModel.onSubmitButtonPressed(currentContext) { [weak self] in
            self?.stopActivityIndicator()
        }
    }
    
    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        setupInputs(viewModel: viewModel)
        setupSubmitButton(title: viewModel.submitButtonTitle)
        details = viewModel.headerText
        logoImage = UIImage(omise: viewModel.logoName)
        
        updateSubmitButtonState()
        applyPrimaryColor()
        applySecondaryColor()
        handleBillingAddress(shouldHide: true)
    }
    
    func setupInputs(viewModel: ViewModel) {
        removeAllInputs()
        
        let fields = viewModel.fields
        for field in fields {
            // Shipping Address section header title
            if field == viewModel.fieldForShippingAddressHeader {
                inputsStackView.addArrangedSubview(SpacerView(vertical: 1))
                inputsStackView.addArrangedSubview(shippingAddressLabel)
            } else if field == viewModel.fieldForBillingAddressHeader {
                inputsStackView.addArrangedSubview(SpacerView(vertical: 1))
                inputsStackView.addArrangedSubview(billingAddressLabel)
            }
            
            let input = TextFieldView(id: field.rawValue)
            inputsStackView.addArrangedSubview(input)
            
            setupInput(input, field: field, isLast: field == fields.last, viewModel: viewModel)
            
            if field == .country {
                input.textFieldUserInteractionEnabled = false
                input.text = viewModel.shippingCountry?.name
                input.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryInputTapped)))
            } else if field == .billingCountry {
                input.textFieldUserInteractionEnabled = false
                input.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBillingCountryInputTapped)))
            } else if field == .postalCode {
                inputsStackView.addArrangedSubview(SpacerView(vertical: 1))
                inputsStackView.addArrangedSubview(billingAddressCheckbox)
                inputsStackView.addArrangedSubview(SpacerView(vertical: 1))
            }
        }
    }
    
    @objc func onCountryInputTapped() {
        openCountryListController(from: .country)
    }
    
    @objc func onBillingCountryInputTapped() {
        openCountryListController(from: .billingCountry)
    }
    
    func setupInput(_ input: TextFieldView, field: Field, isLast: Bool, viewModel: ViewModel) {
        input.title = viewModel.title(for: field)
        input.placeholder = ""
        input.textContentType = viewModel.contentType(for: field)
        input.autocapitalizationType = viewModel.capitalization(for: field)
        input.keyboardType = viewModel.keyboardType(for: field)
        input.autocorrectionType = .no
        
        input.onTextChanged = { [weak self, field] in
            self?.onTextChanged(field: field)
        }
        
        input.onEndEditing = { [weak self, field] in
            self?.onEndEditing(field: field)
        }
        
        input.onBeginEditing = { [weak self, field] in
            self?.onBeginEditing(field: field)
        }
        
        setupOnTextFieldShouldReturn(field: field, isLast: isLast)
    }
    
    func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        inputsStackView.arrangedSubviews.forEach {
            if let input = $0 as? TextFieldView {
                input.textColor = UIColor.omisePrimary
                input.titleColor = UIColor.omisePrimary
            }
        }
    }
    
    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        
        inputsStackView.arrangedSubviews.forEach {
            if let input = $0 as? TextFieldView {
                input.borderColor = UIColor.omiseSecondary
                input.placeholderTextColor = UIColor.omiseSecondary
            }
        }
    }
}

// MARK: Actions
extension AtomePaymentInputsFormController {
    func hideErrorIfNil(field: Field) {
        if let input = input(for: field) {
            let error = viewModel.error(for: field, validate: input.text)
            if error == nil {
                input.error = nil
            }
        }
    }
}

// MARK: Non-private for Unit-Testing
extension AtomePaymentInputsFormController {
    func openCountryListController(from field: Field) {
        let vc = CountryListController(viewModel: viewModel.countryListViewModel)
        vc.title = input(for: field)?.title ?? ""
        vc.viewModel?.onSelectCountry = { [weak self] country in
            guard let self = self else { return }
            self.input(for: field)?.text = country.name
            if field == .billingCountry {
                viewModel.billingCountry = country
            } else {
                viewModel.shippingCountry = country
            }
            self.navigationController?.popToViewController(self, animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllErrors() {
        for field in viewModel.fields {
            updateError(for: field)
        }
    }
    
    func makeViewContext() -> ViewContext {
        var context = ViewContext()
        let fields = viewModel.fields
        for field in fields {
            switch field {
            case .country: context[field] = viewModel.shippingCountry?.code ?? ""
            case .billingCountry: context[field] = viewModel.billingCountry?.code ?? ""
            default: context[field] = input(for: field)?.text ?? ""
            }
        }
        return context
    }
    
    func updateError(for field: Field) {
        guard let input = input(for: field) else { return }
        input.error = viewModel.error(for: field, validate: input.text)
    }
    
    func handleBillingAddress(shouldHide: Bool) {
        billingAddressLabel.isHidden = shouldHide
        for field in viewModel.billingAddressFields {
            guard let input = input(for: field) else { return }
            input.isHidden = shouldHide
            
            if shouldHide {
                input.text = ""
            }
        }
    }
    
    func input(for field: Field) -> TextFieldView? {
        for input in inputsStackView.arrangedSubviews {
            guard let input = input as? TextFieldView, input.identifier == field.rawValue else {
                continue
            }
            return input
        }
        return nil
    }
    
    func input(after input: TextFieldView) -> TextFieldView? {
        guard
            let inputField = Field(rawValue: input.identifier),
            let index = viewModel.fields.firstIndex(of: inputField),
            let nextField = viewModel.fields.at(index + 1),
            let nextInput = self.input(for: nextField) else {
            return nil
        }
        
        if nextInput.textFieldUserInteractionEnabled {
            return nextInput
        } else {
            return self.input(after: nextInput)
        }
    }
}

// MARK: Input Processing
private extension AtomePaymentInputsFormController {
    func onTextChanged(field: Field) {
        updateSubmitButtonState()
        hideErrorIfNil(field: field)
    }
    
    func onEndEditing(field: Field) {
        updateError(for: field)
    }
    
    func onBeginEditing(field: Field) {
        switch field {
        case .phoneNumber: onPhoneNumberBeginEditing()
        default: return
        }
    }
    
    func onPhoneNumberBeginEditing() {
        guard let input = input(for: .phoneNumber) else { return }
        if input.text?.isEmpty ?? true {
            input.text = "+"
        }
    }
    
    func onReturnKeyTapped(field: Field) -> Bool {
        guard let input = input(for: field) else { return true }
        self.onKeboardNextTapped(input: input)
        return false
    }
    
    func setupOnTextFieldShouldReturn(field: Field, isLast: Bool) {
        guard let input = input(for: field) else { return }
        
        if isLast {
            input.returnKeyType = .next
            input.onTextFieldShouldReturn = { [weak self, weak input] in
                guard let self = self, let input = input else { return true }
                self.onKeyboardDoneTapped(input: input)
                return true
            }
        } else {
            input.returnKeyType = .next
            input.onTextFieldShouldReturn = { [weak self, weak input] in
                guard let self = self, let input = input else { return true }
                self.onKeboardNextTapped(input: input)
                return false
            }
        }
    }
    
    func onKeboardNextTapped(input: TextFieldView) {
        if let nextInput = self.input(after: input) {
            _ = nextInput.becomeFirstResponder()
        }
    }
    
    func onKeyboardDoneTapped(input: TextFieldView) {
        if submitButton.isEnabled {
            onSubmitButtonTapped()
        } else {
            showAllErrors()
            goToFirstInvalidField()
        }
    }
    
    func goToFirstInvalidField() {
        for field in viewModel.fields {
            if let input = input(for: field), input.error != nil {
                input.becomeFirstResponder()
                return
            }
        }
        
    }
}
