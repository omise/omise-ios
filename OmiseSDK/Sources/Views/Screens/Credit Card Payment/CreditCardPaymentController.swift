// swiftlint:disable file_length
import UIKit
import Foundation

class CreditCardPaymentController: BaseFormViewController {
    // swiftlint:disable:previous type_body_length
    // MARK: - UI Elements
    // labels
    private lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.text(localized("CreditCard.field.cardNumber"))
        configure(label)
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text(localized("CreditCard.field.nameOnCard"))
        configure(label)
        return label
    }()
    
    private lazy var expiryDateLabel: UILabel = {
        let label = UILabel()
        label.text(localized("CreditCard.field.expiryDate"))
        configure(label)
        return label
    }()
    
    private lazy var cvvLabel: UILabel = {
        let label = UILabel()
        label.text(localized("CreditCard.field.securityCode"))
        configure(label)
        return label
    }()
    
    // fields
    private lazy var cardNumberTextField: CardNumberTextField = {
        let tf = CardNumberTextField()
        tf.rightView = cardBrandImageView
        configure(tf)
        tf.setAccessibilityID("CreditCardForm.cardNumberTextField")
        tf.onValueChanged = { [weak self] in
            guard let self = self else { return }
            let icon = self.viewModel.input.getBrandImage(for: cardNumberTextField.cardBrand)
            self.cardBrandImageView.image = icon.flatMap { UIImage(omise: $0) }
            cardNumberTextField.rightViewMode = self.cardBrandImageView.image != nil ? .always : .never
        }
        return tf
    }()
    
    private lazy var nameTextField: CardNameTextField = {
        let tf = CardNameTextField()
        tf.validator = try? NSRegularExpression(pattern: "\\A[\\w\\s]{1,10}\\s?\\z", options: [])
        tf.setAccessibilityID("CreditCardForm.nameTextField")
        configure(tf)
        return tf
    }()
    
    private lazy var expiryDateTextField: CardExpiryDateTextField = {
        let tf = CardExpiryDateTextField()
        tf.placeholder = localized("CreditCard.field.mmyy.placeholder")
        tf.setAccessibilityID("CreditCardForm.expiryDateTextField")
        configure(tf)
        return tf
    }()
    
    private lazy var cvvTextField: CardCVVTextField = {
        let tf = CardCVVTextField()
        tf.setAccessibilityID("CreditCardForm.cvvTextField")
        tf.rightView = infoButton
        tf.rightViewMode = .always
        configure(tf)
        return tf
    }()
    
    // Error Labels
    private lazy var cardNumberErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.setAccessibilityID("CreditCardForm.cardNumberError")
        configureError(label)
        return label
    }()
    
    private lazy var nameErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.setAccessibilityID("CreditCardForm.cardNameError")
        configureError(label)
        return label
    }()
    
    private lazy var expiryDateErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.setAccessibilityID("CreditCardForm.expiryDateError")
        configureError(label)
        return label
    }()
    
    private lazy var cvvErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.setAccessibilityID("CreditCardForm.cvvError")
        configureError(label)
        return label
    }()
    
    // address textfield views
    private lazy var countryFieldView: TextFieldView = {
        let view = TextFieldView(id: "country")
        view.title = "CreditCard.field.country".localized()
        view.titleColor = .omisePrimary
        view.textColor = .omisePrimary
        view.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.textFieldUserInteractionEnabled = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryInputTapped)))
        return view
    }()
    
    private lazy var addressFieldView: TextFieldView = {
        let view = TextFieldView(id: CreditCardAddressField.address.id)
        configureFieldView(view)
        return view
    }()
    
    private lazy var cityFieldView: TextFieldView = {
        let view = TextFieldView(id: CreditCardAddressField.city.id)
        configureFieldView(view)
        return view
    }()
    
    private lazy var stateFieldView: TextFieldView = {
        let view = TextFieldView(id: CreditCardAddressField.state.id)
        configureFieldView(view)
        return view
    }()
    
    private lazy var zipCodeFieldView: TextFieldView = {
        let view = TextFieldView(id: CreditCardAddressField.postalCode.id)
        configureFieldView(view)
        return view
    }()
    
    private lazy var submitButton: MainActionButton = {
        let button = MainActionButton()
        configure(button)
        button.setTitle(localized("CreditCard.payButton.title"), for: .normal)
        button.addTarget(self, action: #selector(submitCardForm(_:)), for: .touchUpInside)
        button.setAccessibilityID("CreditCardForm.submitButton")
        return button
    }()
    
    private lazy var cancelButtonItem: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain,
            target: self,
            action: #selector(cancelForm)
        )
    }()
    
    // accessories
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(omise: "More Info"), for: .normal)
        button.tintColor = .badgeBackground
        button.addTarget(self, action: #selector(showCVVInfo), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardBrandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image(UIImage(omise: "Visa"))
            .contentMode(.scaleAspectFit)
            .translatesAutoresizingMaskIntoConstraints(false)
        return imageView
    }()
    
    // groups
    private lazy var formStack: UIStackView = {
        let stack = UIStackView()
        stack.axis(.vertical)
            .alignment(.fill)
            .spacing(spacing)
            .translatesAutoresizingMaskIntoConstraints(false)
        return stack
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis(.horizontal)
            .alignment(.fill)
            .spacing(spacing)
            .translatesAutoresizingMaskIntoConstraints(false)
        return stack
    }()
    
    private lazy var addressStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis(.vertical)
            .distribution(.equalSpacing)
            .alignment(.fill)
            .spacing(spacing)
            .setAccessibilityID("CreditCardForm.addressStackView")
            .translatesAutoresizingMaskIntoConstraints(false)
        return stack
    }()
    
    let viewModel: CreditCardPaymentFormViewModelProtocol
    
    // MARK: - Initialization
    init(viewModel: CreditCardPaymentFormViewModelProtocol) {
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
        handleAddressFieldsDisplay()
        setupHandlers()
        configureAccessibility()
        viewModel.input.viewDidLoad()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.rightBarButtonItem = cancelButtonItem
        
        contentView.addSubviewAndFit(formStack, vertical: padding, horizontal: padding)
        formStack.constrainWidth(equalTo: contentView, constant: -(padding * 2))
        
        hStack.addArrangedSubviews([
            getStackViewGroup(for: [expiryDateLabel, expiryDateTextField, expiryDateErrorLabel]),
            getStackViewGroup(for: [cvvLabel, cvvTextField, cvvErrorLabel])
        ])
        
        addressStackView.addArrangedSubviews([
            addressFieldView,
            cityFieldView,
            stateFieldView,
            zipCodeFieldView
        ])
        
        // each row: Label → TextField → ErrorLabel
        formStack.addArrangedSubviews([
            getStackViewGroup(for: [cardNumberLabel, cardNumberTextField, cardNumberErrorLabel]),
            getStackViewGroup(for: [nameLabel, nameTextField, nameErrorLabel]),
            hStack,
            countryFieldView,
            addressStackView,
            submitButton
        ])
        
        // activity spinner
        contentView.addSubview(requestingIndicatorView)
        requestingIndicatorView.setToCenter(of: submitButton)
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
        
        viewModel.input.set { [weak self] country in
            guard let self = self else { return }
            self.countryFieldView.text = country.name
            self.dismissViewController()
            self.handleAddressFieldsDisplay()
            self.validateFieldData()
        }
    }
    
    private func setupFormFields() {
        // let BaseFormViewController handle keyboard insets & next/done
        formFields = [
            cardNumberTextField,
            nameTextField,
            expiryDateTextField,
            cvvTextField
        ]
        
        if viewModel.output.shouldShouldAddressFields {
            formFields.append(contentsOf: [
                addressFieldView.textField,
                cityFieldView.textField,
                stateFieldView.textField,
                zipCodeFieldView.textField
            ])
        }
        
        contentView.adjustContentInsetOnKeyboardAppear()
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
    
    private func handleAddressFieldsDisplay() {
        addressStackView.isHidden = !viewModel.output.shouldShouldAddressFields
        setupFormFields()
        setupTextFieldHandlers()
    }
    
    // MARK: - Form Submission
    @objc func submitCardForm(_ sender: UIButton) {
        guard let pan = cardNumberTextField.text?.trimmingCharacters(in: .whitespaces),
              let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let expiryMonth = expiryDateTextField.selectedMonth,
              let expiryYear = expiryDateTextField.selectedYear,
              let cvv = cvvTextField.text?.trimmingCharacters(in: .whitespaces),
              let country = countryFieldView.text?.trimmingCharacters(in: .whitespaces) else { return }
        
        let payment = CreditCardPayment(pan: pan,
                                        name: name,
                                        expiryMonth: expiryMonth,
                                        expiryYear: expiryYear,
                                        cvv: cvv,
                                        country: country,
                                        address: addressFieldView.text,
                                        state: stateFieldView.text,
                                        city: cityFieldView.text,
                                        zipcode: zipCodeFieldView.text)
        viewModel.input.startPayment(for: payment)
    }
    
    @objc func cancelForm() {
        viewModel.input.didCancelForm()
    }
    
    @objc func showCVVInfo() {
        guard let targetView = view.window ?? view else { return }
        
        let cvv = CVVInfoView()
        cvv.tintColor = view.tintColor
        cvv.preferredCardBrand = cardNumberTextField.cardBrand
        cvv.onCloseTapped = {[weak self] in
            guard let self = self else { return }
            self.dismissCVVInfo(cvv)
        }
        
        UIView.transition(
            with: targetView,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: ({ targetView.addSubviewAndFit(cvv) })
        )
    }
    
    @objc func onCountryInputTapped() {
        let vc = CountryListController(viewModel: viewModel.output.countryViewModel)
        vc.title = countryFieldView.title
        presentViewController(vc)
    }
    
    private func dismissCVVInfo(_ cvvView: UIView) {
        guard let targetView = view.window ?? view else { return }
        
        UIView.transition(
            with: targetView,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: ({ cvvView.removeFromSuperview() }))
    }
    
    func validateField(_ textField: OmiseTextField) {
        if isAddressTagGroup(textField) {
            validateAddressFields(textField)
            return
        }
        
        guard let errorLabel = associatedErrorLabel(of: textField) else { return }
        do {
            try textField.validate()
            errorLabel.alpha(0.0)
        } catch {
            switch (error, textField) {
            case (OmiseTextFieldValidationError.emptyText, _):
                errorLabel.text("-")
            case (OmiseTextFieldValidationError.invalidData, cardNumberTextField):
                errorLabel.text(viewModel.output.numberError)
            case (OmiseTextFieldValidationError.invalidData, nameTextField):
                errorLabel.text(viewModel.output.nameError)
            case (OmiseTextFieldValidationError.invalidData, expiryDateTextField):
                errorLabel.text(viewModel.output.expiryError)
            case (OmiseTextFieldValidationError.invalidData, cvvTextField):
                errorLabel.text(viewModel.output.cvvError)
            default:
                errorLabel.text(error.localizedDescription)
            }
            errorLabel.alpha(errorLabel.text != "-" ? 1.0 : 0.0)
        }
    }
    
    func validateAddressFields(_ textField: OmiseTextField) {
        do {
            try textField.validate()
        } catch {
            switch (error, textField) {
            case (OmiseTextFieldValidationError.emptyText, addressFieldView.textField):
                setErrorMessage(for: addressFieldView)
            case (OmiseTextFieldValidationError.emptyText, cityFieldView.textField):
                setErrorMessage(for: cityFieldView)
            case (OmiseTextFieldValidationError.emptyText, stateFieldView.textField):
                setErrorMessage(for: stateFieldView)
            case (OmiseTextFieldValidationError.emptyText, zipCodeFieldView.textField):
                setErrorMessage(for: zipCodeFieldView)
            default:
                break
            }
        }
    }
    
    func clearErrorMessage(for field: OmiseTextField) {
        switch field.tag {
        case addressFieldTag: addressFieldView.error = nil
        case cityFieldTag: cityFieldView.error = nil
        case stateFieldTag: stateFieldView.error = nil
        case zipCodeFieldTag: zipCodeFieldView.error = nil
        default: break
        }
    }
}

// MARK: - TextFields Helper
extension CreditCardPaymentController {
    func setupTextFieldHandlers() {
        for field in formFields {
            field.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
            field.addTarget(self, action: #selector(textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
            field.addTarget(self, action: #selector(validateFieldData), for: .editingChanged)
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
            guard let self = self else { return }
            
            if self.isAddressTagGroup(textField) {
                self.clearErrorMessage(for: textField)
            } else if let errorLabel = self.associatedErrorLabel(of: textField) {
                errorLabel.alpha = 0.0
            }
        }
        updateNavigationButtons(for: textField)
    }
    
    @objc func textFieldEditingDidEndOnExit(_ textField: OmiseTextField) {
        gotoNextField()
    }
    
    @discardableResult
    @objc func validateFieldData() -> Bool {
        let isEnabled: Bool = formFields.allSatisfy { $0.isValid } && countryFieldView.text?.isEmpty == false
        submitButton.isEnabled = isEnabled
        return isEnabled
    }
    
    @objc func validateTextFieldDataOf(_ textField: OmiseTextField) {
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
            
            self.validateField(textField)
        }
        textField.borderColor = .omiseSecondary
    }
    
    func associatedErrorLabel(of textField: OmiseTextField) -> UILabel? {
        switch textField {
        case nameTextField: return nameErrorLabel
        case cardNumberTextField: return cardNumberErrorLabel
        case expiryDateTextField: return expiryDateErrorLabel
        case cvvTextField: return cvvErrorLabel
        default: return nil
        }
    }
}

// MARK: - Accessibility
extension CreditCardPaymentController {
    func configureAccessibility() {
        accessibilityCustomRotors = [
            UIAccessibilityCustomRotor(name: "Fields") { [weak self] (predicate) -> UIAccessibilityCustomRotorItemResult? in
                let fields = self?.formFields ?? []
                return self?.accessibilityElementAfter(predicate.currentItem.targetElement,
                                                       fields: fields,
                                                       matchingPredicate: { _ in true },
                                                       direction: predicate.searchDirection)
                .map { UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) }
            },
            
            UIAccessibilityCustomRotor(name: "Invalid Data Fields") { [weak self] (predicate) -> UIAccessibilityCustomRotorItemResult? in
                let fields = self?.formFields ?? []
                return self?.accessibilityElementAfter(predicate.currentItem.targetElement,
                                                       fields: fields,
                                                       matchingPredicate: { !$0.isValid },
                                                       direction: predicate.searchDirection)
                .map { UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) }
            }
        ]
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        guard validateFieldData() else {
            return false
        }
        
        submitCardForm(submitButton)
        return true
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancelForm()
        return true
    }
    
    func accessibilityElementAfter(
        _ element: NSObjectProtocol?,
        fields: [OmiseTextField],
        matchingPredicate predicate: (OmiseTextField) -> Bool,
        direction: UIAccessibilityCustomRotor.Direction
    ) -> NSObjectProtocol? {
        guard let element = element else {
            return handleNoElement(direction, fields: fields, matchingPredicate: predicate)
        }
        return findAccessibilityElement(element, fields: fields, matchingPredicate: predicate, direction: direction)
    }
    
    // This could be the new helper function handling cases when no element is provided
    func handleNoElement(
        _ direction: UIAccessibilityCustomRotor.Direction,
        fields: [OmiseTextField],
        matchingPredicate predicate: (OmiseTextField) -> Bool
    ) -> NSObjectProtocol? {
        
        switch direction {
        case .previous:
            return fields.reversed().first(where: predicate)?.accessibilityElements?.last as? NSObjectProtocol
            ?? fields.reversed().first(where: predicate)
        case .next:
            fallthrough
        @unknown default:
            return fields.first(where: predicate)?.accessibilityElements?.first as? NSObjectProtocol
            ?? fields.first(where: predicate)
        }
    }
    
    // This could be another helper function finding an accessibility element
    func findAccessibilityElement(
        _ element: NSObjectProtocol,
        fields: [OmiseTextField],
        matchingPredicate predicate: (OmiseTextField) -> Bool,
        direction: UIAccessibilityCustomRotor.Direction
    ) -> NSObjectProtocol? {
        let fieldOfElement = fields.first { field in
            guard let accessibilityElements = field.accessibilityElements as? [NSObjectProtocol] else {
                return element === field
            }
            
            return accessibilityElements.contains { $0 === element }
        } ?? cardNumberTextField
        
        let nextField = filedAfter(fieldOfElement, fields: fields, matchingPredicate: predicate, direction: direction)
        
        guard let currentAccessibilityElements = (fieldOfElement.accessibilityElements as? [NSObjectProtocol]),
              let indexOfAccessibilityElement = currentAccessibilityElements.firstIndex(where: { $0 === element }) else {
            switch direction {
            case .previous:
                return nextField?.accessibilityElements?.last as? NSObjectProtocol ?? nextField
            case .next:
                fallthrough
            @unknown default:
                return nextField?.accessibilityElements?.first as? NSObjectProtocol ?? nextField
            }
        }
        
        switch direction {
        case .previous:
            if predicate(fieldOfElement) && indexOfAccessibilityElement > currentAccessibilityElements.startIndex {
                return currentAccessibilityElements[currentAccessibilityElements.index(before: indexOfAccessibilityElement)]
            } else {
                return nextField?.accessibilityElements?.last as? NSObjectProtocol ?? nextField
            }
        case .next:
            fallthrough
        @unknown default:
            if predicate(fieldOfElement) && indexOfAccessibilityElement < currentAccessibilityElements.endIndex - 1 {
                return currentAccessibilityElements[currentAccessibilityElements.index(after: indexOfAccessibilityElement)]
            } else {
                return nextField?.accessibilityElements?.first as? NSObjectProtocol ?? nextField
            }
        }
    }
    
    func filedAfter(
        _ field: OmiseTextField,
        fields: [OmiseTextField],
        matchingPredicate predicate: (OmiseTextField) -> Bool,
        direction: UIAccessibilityCustomRotor.Direction
    ) -> OmiseTextField? {
        guard let indexOfField = fields.firstIndex(of: field) else { return nil }
        switch direction {
        case .previous:
            return fields[fields.startIndex..<indexOfField].reversed().first(where: predicate)
        case .next: fallthrough
        @unknown default:
            return fields[fields.index(after: indexOfField)...].first(where: predicate)
        }
    }
}
