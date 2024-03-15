// swiftlint:disable file_length

import UIKit
import os.log

/// Drop-in credit card input form view controller that automatically tokenizes credit
/// card information.
class CreditCardPaymentController: UIViewController {
    // swiftlint:disable:previous type_body_length

    typealias ViewModel = CreditCardPaymentViewModel
    typealias ViewContext = CreditCardPaymentViewContext
    typealias Field = ViewContext.Field

    struct Style {
        var billingStackSpacing = CGFloat(12)
    }
    var style = Style()

    var viewModel: ViewModel? {
        didSet {
            if let newViewModel = viewModel {
                bind(to: newViewModel)
            }
        }
    }

    @IBInspectable var errorMessageTextColor: UIColor! = CreditCardPaymentController.defaultErrorMessageTextColor {
        didSet {
            if errorMessageTextColor == nil {
                errorMessageTextColor = CreditCardPaymentController.defaultErrorMessageTextColor
            }

            if isViewLoaded {
                errorLabels.forEach {
                    $0.textColor = errorMessageTextColor
                }
            }
        }
    }

    var isInputDataValid: Bool {
        return formFields.allSatisfy { $0.isValid }
    }

    var currentEditingTextField: OmiseTextField?
    var hasErrorMessage = false

    var formFields: [OmiseTextField] = []
    var formLabels: [UILabel] = []

    var errorLabels: [UILabel] = []
    @IBOutlet var contentView: UIScrollView!

    @IBOutlet var cardNumberLabel: UILabel!
    @IBOutlet var cardNameLabel: UILabel!
    @IBOutlet var expiryDateLabel: UILabel!
    @IBOutlet var secureCodeLabel: UILabel!

    @IBOutlet var cardNumberTextField: CardNumberTextField!
    @IBOutlet var cardNameTextField: CardNameTextField!
    @IBOutlet var expiryDateTextField: CardExpiryDateTextField!
    @IBOutlet var secureCodeTextField: CardCVVTextField!

    let countryInputView = TextFieldView(id: "country")

    @IBOutlet var submitButton: MainActionButton!

    @IBOutlet var formFieldsAccessoryView: UIToolbar!
    @IBOutlet var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var gotoNextFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneEditingBarButtonItem: UIBarButtonItem!

    @IBOutlet var creditCardNumberErrorLabel: UILabel!
    @IBOutlet var cardHolderNameErrorLabel: UILabel!
    @IBOutlet var cardExpiryDateErrorLabel: UILabel!
    @IBOutlet var cardSecurityCodeErrorLabel: UILabel!

    @IBOutlet var errorBannerView: UIView!
    @IBOutlet var errorTitleLabel: UILabel!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var hidingErrorBannerConstraint: NSLayoutConstraint!
    @IBOutlet var emptyErrorMessageConstraint: NSLayoutConstraint!
    @IBOutlet var cardBrandIconImageView: UIImageView!
    @IBOutlet var cvvInfoButton: UIButton!
    @IBOutlet var billingStackView: UIStackView!

    lazy var addressStackView: UIStackView = {
        let verticalContainerStack = UIStackView()
        verticalContainerStack.axis = .vertical
        verticalContainerStack.distribution = .equalSpacing
        verticalContainerStack.alignment = .fill
        verticalContainerStack.spacing = style.billingStackSpacing
        return verticalContainerStack
    }()

    @IBOutlet var requestingIndicatorView: UIActivityIndicatorView!
    static let defaultErrorMessageTextColor = UIColor.error

    func setCreditCardInformationWith(number: String?, name: String?, expiration: (month: Int, year: Int)?) {
        cardNumberTextField.text = number
        cardNameTextField.text = name

        if let expiration = expiration, 1...12 ~= expiration.month, expiration.year > 0 {
            expiryDateTextField.text = String(format: "%02d/%d", expiration.month, expiration.year % 100)
        }

        updateSupplementaryUI()

        os_log("The custom credit card information was set - %{private}@", log: uiLogObject, type: .debug, String((number ?? "").suffix(4)))
    }

    func setupArrays() {
        errorLabels = [
            cardHolderNameErrorLabel,
            creditCardNumberErrorLabel,
            cardExpiryDateErrorLabel,
            cardSecurityCodeErrorLabel
        ]

        formLabels = [
            cardNameLabel,
            cardNumberLabel,
            expiryDateLabel,
            secureCodeLabel
        ]

        formFields = [
            cardNumberTextField,
            cardNameTextField,
            expiryDateTextField,
            secureCodeTextField
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupArrays()

        if #available(iOSApplicationExtension 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        view.backgroundColor = UIColor.omiseBackground

        cvvInfoButton.tintColor = .badgeBackground
        formFieldsAccessoryView.barTintColor = .formAccessoryBarTintColor

        applyNavigationBarStyle(.shadow(color: .omiseSecondary))

        setShowsErrorBanner(false)
        setupBillingStackView()
        setupAddressFields()

        applyPrimaryColor()
        applySecondaryColor()

        updateSupplementaryUI()

        configureAccessibility()

        if  #unavailable(iOS 11) {
            // We'll leave the adjusting scroll view insets job for iOS 11 and later to the layoutMargins + safeAreaInsets here
            automaticallyAdjustsScrollViewInsets = true
        }

        setupLabels()
        setupTextFields()
        setupSubmitButton()
        setupCancelButton()

        contentView.adjustContentInsetOnKeyboardAppear()

        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }

    private func setupLabels() {
        errorLabels.forEach {
            $0.textColor = errorMessageTextColor
        }

        formLabels.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        
        cardNumberLabel.text = localized("CreditCard.field.cardNumber")
        cardNameLabel.text = localized("CreditCard.field.nameOnCard")
        expiryDateLabel.text = localized("CreditCard.field.expiryDate")
        secureCodeLabel.text = localized("CreditCard.field.securityCode")
    }

    private func setupTextFields() {
        expiryDateTextField.placeholder = localized("CreditCard.field.mmyy.placeholder")

        formFields.forEach {
            $0.inputAccessoryView = formFieldsAccessoryView
            $0.onValueChanged = { [weak self] in
                self?.updateAccessibilityValue()
            }
        }

        formFields.forEach {
            $0.adjustsFontForContentSizeCategory = true
            setupTextFieldAction($0)
        }

        cardNumberTextField.textContentType = .creditCardNumber
        cardNumberTextField.textContentType = .creditCardNumber
        cardNumberTextField.rightView = cardBrandIconImageView
        secureCodeTextField.rightView = cvvInfoButton
        secureCodeTextField.rightViewMode = .always
    }

    private func setupTextFieldAction(_ field: OmiseTextField) {
        field.addTarget(self, action: #selector(updateAccessibilityValue), for: .editingChanged)
        field.addTarget(self, action: #selector(updateInputAccessoryViewFor), for: .editingDidBegin)
        field.addTarget(self, action: #selector(validateTextFieldDataOf), for: .editingDidEnd)
    }

    private func setupSubmitButton() {
        submitButton.setTitle(localized("CreditCard.payButton.title"), for: .normal)
        submitButton.defaultBackgroundColor = view.tintColor
        submitButton.disabledBackgroundColor = .line
        submitButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    private func setupCancelButton() {
        let cancelButtonItem = UIBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain,
            target: self,
            action: #selector(cancelForm)
        )
        navigationItem.rightBarButtonItem = cancelButtonItem
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter().removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            view.setNeedsUpdateConstraints()
        }
    }

    private func setupBillingStackView() {
        billingStackView.distribution = .equalSpacing
        billingStackView.alignment = .fill
        billingStackView.spacing = style.billingStackSpacing
        setupCountryField()
    }

    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        countryInputView.text = viewModel.countryListViewModel.selectedCountry?.name
        
        viewModel.addressFields.forEach {
            let input = TextFieldView(id: $0.rawValue)
            addressStackView.addArrangedSubview(input)
            setupInput(input, field: $0, isLast: $0 == viewModel.addressFields.last, viewModel: viewModel)
        }
        addressStackView.isHiddenInStackView = !viewModel.isAddressFieldsVisible
        updateSupplementaryUI()
    }

    private  func setupCountryField() {
        let input = countryInputView
        input.title = "CreditCard.field.country".localized()
        billingStackView.addArrangedSubview(input)

        input.textFieldUserInteractionEnabled = false
        input.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryInputTapped)))
    }

    @objc func onCountryInputTapped() {
        guard let viewModel = viewModel else { return }

        let vc = CountryListController(viewModel: viewModel.countryListViewModel)
        vc.title = countryInputView.title
        vc.viewModel?.onSelectCountry = { [weak self] country in
            guard let self = self, let viewModel = self.viewModel else { return }
            self.countryInputView.text = country.name

            if let nc = self.navigationController {
                nc.popToViewController(self, animated: true)
            } else {
                self.dismiss(animated: true)
            }

            self.addressStackView.isHiddenInStackView = !viewModel.isAddressFieldsVisible
            self.updateSubmitButtonState()

        }

        if let nc = navigationController {
            nc.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }

    func setupAddressFields() {
        billingStackView.addArrangedSubview(addressStackView)
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

    @IBAction private func presentCVVInfo(_ sender: UIButton) {
        guard let targetView = view.window ?? view else { return }

        let ccvInfoController = CCVInfoController(nibName: nil, bundle: .omiseSDK)

        ccvInfoController.view.tintColor = view.tintColor
        ccvInfoController.preferredCardBrand = cardNumberTextField.cardBrand
        ccvInfoController.onCloseTapped = { [weak self, weak ccvInfoController] in
            guard let self = self, let ccvInfoController = ccvInfoController else { return }
            self.dismissCVVInfo(ccvInfoController)
        }

        UIView.transition(
            with: targetView,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: {
                targetView.addSubviewAndFit(ccvInfoController.view)
            }, completion: { _ in
                self.addChild(ccvInfoController)
            })
    }

    private func dismissCVVInfo(_ ccvInfoController: CCVInfoController) {
        guard let targetView = view.window ?? view else { return }

        UIView.transition(
            with: targetView,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: {
                ccvInfoController.view.removeFromSuperview()
                ccvInfoController.removeFromParent()
            }, completion: nil)
    }

    @IBAction private func cancelForm() {
        performCancelingForm()
    }

    @discardableResult
    func performCancelingForm() -> Bool {
        guard let viewModel = viewModel else { return false }
        viewModel.viewDidTapClose()
        return true
    }

    func makeViewContext() -> ViewContext {
        guard let viewModel = viewModel else { return ViewContext() }

        var context = ViewContext()
        let fields = viewModel.addressFields
        for field in fields {
            switch field {
            default: context[field] = input(for: field)?.text ?? ""
            }
        }

        context.countryCode = viewModel.countryListViewModel.selectedCountry?.code ?? ""
        context.number = cardNumberTextField.text ?? ""
        context.name = cardNameTextField.text ?? ""
        context.expirationMonth = expiryDateTextField.selectedMonth ?? 0
        context.expirationYear = expiryDateTextField.selectedYear ?? 0
        context.securityCode = secureCodeTextField.text ?? ""

        return context
    }

    @IBAction private func requestToken() {
        doneEditing(nil)
        guard let viewModel = viewModel else { return }

        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "Submitting payment, please wait")
        startActivityIndicator()
        viewModel.onSubmitButtonPressed(makeViewContext()) {
            self.stopActivityIndicator()
        }
    }

    func keyboardWillAppear(_ notification: Notification) {
        if hasErrorMessage {
            hasErrorMessage = false
            dismissErrorMessage(animated: true, sender: self)
        }
    }

    func keyboardWillChangeFrame(_ notification: NSNotification) {
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

    func handleError(_ error: Error) {
//        delegate?.creditCardFormViewController(self, didFailWithError: error)
        displayError(error)
        hasErrorMessage = true
    }

    func displayError(_ error: Error) {
        let targetController = targetViewController(forAction: #selector(UIViewController.displayErrorWith(title:message:animated:sender:)),
                                                    sender: self)
        if let targetController = targetController, targetController !== self {
            if let error = error as? OmiseError {
                targetController.displayErrorWith(title: error.localizedDescription,
                                                  message: error.localizedRecoverySuggestion,
                                                  animated: true,
                                                  sender: self)
            } else if let error = error as? LocalizedError {
                targetController.displayErrorWith(title: error.localizedDescription,
                                                  message: error.recoverySuggestion,
                                                  animated: true,
                                                  sender: self)
            } else {
                targetController.displayErrorWith(title: error.localizedDescription,
                                                  message: nil,
                                                  animated: true,
                                                  sender: self)
            }
        } else {
            let errorTitle: String
            let errorMessage: String?
            if let error = error as? OmiseError {
                errorTitle = error.localizedDescription
                errorMessage = error.localizedRecoverySuggestion
            } else if let error = error as? LocalizedError {
                errorTitle = error.localizedDescription
                errorMessage = error.recoverySuggestion
            } else {
                errorTitle = error.localizedDescription
                errorMessage = nil
            }

            errorTitleLabel.text = errorTitle
            errorMessageLabel.text = errorMessage

            errorMessageLabel.isHidden = errorMessage == nil
            emptyErrorMessageConstraint.priority = errorMessage == nil ? UILayoutPriority(999) : UILayoutPriority(1)
            errorBannerView.layoutIfNeeded()

            setShowsErrorBanner(true)
        }
    }

    func setShowsErrorBanner(_ showsErrorBanner: Bool, animated: Bool = true) {
        hidingErrorBannerConstraint.isActive = !showsErrorBanner

        let animationBlock = {
            self.errorBannerView.alpha = showsErrorBanner ? 1.0 : 0.0
            self.contentView.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                           delay: 0.0,
                           options: [.layoutSubviews],
                           animations: animationBlock)
        } else {
            animationBlock()
        }
    }

    @IBAction private func dismissErrorBanner(_ sender: Any) {
        setShowsErrorBanner(false)
    }

    func updateSupplementaryUI() {
        updateSubmitButtonState()

        let cardBrandIconName: String?
        switch cardNumberTextField.cardBrand {
        case .visa?:
            cardBrandIconName = "Visa"
        case .masterCard?:
            cardBrandIconName = "Mastercard"
        case .jcb?:
            cardBrandIconName = "JCB"
        case .amex?:
            cardBrandIconName = "AMEX"
        case .diners?:
            cardBrandIconName = "Diners"
        default:
            cardBrandIconName = nil
        }
        cardBrandIconImageView.image = cardBrandIconName.flatMap { UIImage(omise: $0) }
        cardNumberTextField.rightViewMode = cardBrandIconImageView.image != nil ? .always : .never
    }

    func startActivityIndicator() {
        requestingIndicatorView.startAnimating()
        submitButton.isEnabled = false
        view.isUserInteractionEnabled = false
    }

    func stopActivityIndicator() {
        requestingIndicatorView.stopAnimating()
        submitButton.isEnabled = true
        view.isUserInteractionEnabled = true
    }

    func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

        formFields.forEach {
            $0.textColor = UIColor.omisePrimary
        }
        formLabels.forEach {
            $0.textColor = UIColor.omisePrimary
        }

        let textFields: [UIView] =
        billingStackView.arrangedSubviews.filter { $0.isKind(of: TextFieldView.self) } +
        addressStackView.arrangedSubviews.filter { $0.isKind(of: TextFieldView.self) }

        textFields.forEach {
            if let input = $0 as? TextFieldView {
                input.textColor = UIColor.omisePrimary
            }
        }

    }

    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }

        formFields.forEach {
            $0.borderColor = UIColor.omiseSecondary
            $0.placeholderTextColor = UIColor.omiseSecondary
        }

        let textFields: [UIView] =
        billingStackView.arrangedSubviews.filter { $0.isKind(of: TextFieldView.self) } +
        addressStackView.arrangedSubviews.filter { $0.isKind(of: TextFieldView.self) }

        textFields.forEach {
            if let input = $0 as? TextFieldView {
                input.titleColor = UIColor.omisePrimary
                input.borderColor = UIColor.omiseSecondary
                input.placeholderTextColor = UIColor.omiseSecondary
            }
        }
    }

    func associatedErrorLabelOf(_ textField: OmiseTextField) -> UILabel? {
        switch textField {
        case cardNumberTextField:
            return creditCardNumberErrorLabel
        case cardNameTextField:
            return cardHolderNameErrorLabel
        case expiryDateTextField:
            return cardExpiryDateErrorLabel
        case secureCodeTextField:
            return cardSecurityCodeErrorLabel
        default:
            return nil
        }
    }

    func validateField(_ textField: OmiseTextField) {
        guard let errorLabel = associatedErrorLabelOf(textField) else {
            return
        }
        do {
            try textField.validate()
            errorLabel.alpha = 0.0
        } catch {
            errorLabel.text = validationErrorText(for: textField, error: error)
            errorLabel.alpha = errorLabel.text != "-" ? 1.0 : 0.0
        }
    }

    func validationErrorText(for textField: UITextField, error: Error) -> String {
        switch (error, textField) {
        case (OmiseTextFieldValidationError.emptyText, _):
            return "-" // We need to set the error label some string in order to have it retains its height

        case (OmiseTextFieldValidationError.invalidData, cardNumberTextField):
            return NSLocalizedString(
                "credit-card-form.card-number-field.invalid-data.error.text",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Credit card number is invalid",
                comment: "An error text displayed when the credit card number is invalid"
            )
        case (OmiseTextFieldValidationError.invalidData, cardNameTextField):
            return NSLocalizedString(
                "credit-card-form.card-holder-name-field.invalid-data.error.text",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Card holder name is invalid",
                comment: "An error text displayed when the card holder name is invalid"
            )
        case (OmiseTextFieldValidationError.invalidData, expiryDateTextField):
            return NSLocalizedString(
                "credit-card-form.expiry-date-field.invalid-data.error.text",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Card expiry date is invalid",
                comment: "An error text displayed when the expiry date is invalid"
            )
        case (OmiseTextFieldValidationError.invalidData, secureCodeTextField):
            return NSLocalizedString(
                "credit-card-form.security-code-field.invalid-data.error.text",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "CVV code is invalid",
                comment: "An error text displayed when the security code is invalid"
            )

        case (_, cardNumberTextField),
            (_, cardNameTextField),
            (_, expiryDateTextField),
            (_, secureCodeTextField):
            return error.localizedDescription
        default:
            return "-"
        }
    }
}

// MARK: - Fields Accessory methods
extension CreditCardPaymentController {

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
        if let errorLabel = associatedErrorLabelOf(sender) {
            let duration = TimeInterval(UINavigationController.hideShowBarDuration)
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
                errorLabel.alpha = 0.0
            }
        }

        sender.borderColor = view.tintColor
        updateInputAccessoryViewWithFirstResponder(sender)
    }

    @IBAction private func gotoPreviousField(_ button: UIBarButtonItem) {
        gotoPreviousField()
    }

    @IBAction private func gotoNextField(_ button: UIBarButtonItem) {
        gotoNextField()
    }

    @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }
}

// MARK: - Accessibility
extension CreditCardPaymentController {

    @IBAction private func updateAccessibilityValue() {
        updateSupplementaryUI()
    }

    // swiftlint:disable:next function_body_length
    func configureAccessibility() {
        formLabels.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        formFields.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }

        let fields = formFields

        submitButton.titleLabel?.adjustsFontForContentSizeCategory = true

        // swiftlint:disable:next function_body_length
        func accessiblityElementAfter(
            _ element: NSObjectProtocol?,
            matchingPredicate predicate: (OmiseTextField) -> Bool,
            direction: UIAccessibilityCustomRotor.Direction
        ) -> NSObjectProtocol? {
            guard let element = element else {
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

            let fieldOfElement = fields.first { field in
                guard let accessibilityElements = field.accessibilityElements as? [NSObjectProtocol] else {
                    return element === field
                }

                return accessibilityElements.contains { $0 === element }
            } ?? cardNumberTextField! // swiftlint:disable:this force_unwrapping

            func filedAfter(
                _ field: OmiseTextField,
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

            let nextField = filedAfter(fieldOfElement, matchingPredicate: predicate, direction: direction)

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

        accessibilityCustomRotors = [
            UIAccessibilityCustomRotor(name: "Fields") { (predicate) -> UIAccessibilityCustomRotorItemResult? in
                return accessiblityElementAfter(predicate.currentItem.targetElement,
                                                matchingPredicate: { _ in true },
                                                direction: predicate.searchDirection)
                .map { UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) }
            },
            UIAccessibilityCustomRotor(name: "Invalid Data Fields") { (predicate) -> UIAccessibilityCustomRotorItemResult? in
                return accessiblityElementAfter(predicate.currentItem.targetElement,
                                                matchingPredicate: { !$0.isValid },
                                                direction: predicate.searchDirection)
                .map { UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) }
            }
        ]
    }

    override func accessibilityPerformMagicTap() -> Bool {
        guard isInputDataValid else {
            return false
        }

        requestToken()
        return true
    }

    override func accessibilityPerformEscape() -> Bool {
        return performCancelingForm()
    }
}

extension CreditCardPaymentController {
    func updateSubmitButtonState() {
        guard let viewModel = viewModel else { return }

        let valid = isInputDataValid
        submitButton?.isEnabled = valid && viewModel.isSubmitButtonEnabled(makeViewContext())

        if valid {
            submitButton.accessibilityTraits.remove(UIAccessibilityTraits.notEnabled)
        } else {
            submitButton.accessibilityTraits.insert(UIAccessibilityTraits.notEnabled)
        }
    }

    func updateError(for field: Field) {
        guard let viewModel = viewModel else { return }
        guard let input = input(for: field) else { return }
        input.error = viewModel.error(for: field, validate: input.text)
    }

    func input(for field: Field) -> TextFieldView? {
        let arrangedSubviews = addressStackView.arrangedSubviews + billingStackView.arrangedSubviews
        for input in arrangedSubviews {
            guard let input = input as? TextFieldView, input.identifier == field.rawValue else {
                continue
            }
            return input
        }
        return nil
    }

    func input(after input: TextFieldView) -> TextFieldView? {
        guard
            let viewModel = viewModel,
            let inputField = Field(rawValue: input.identifier),
            let index = viewModel.addressFields.firstIndex(of: inputField),
            let nextField = viewModel.addressFields.at(index + 1),
            let nextInput = self.input(for: nextField) else {
            return nil
        }

        if nextInput.textFieldUserInteractionEnabled {
            return nextInput
        } else {
            return self.input(after: nextInput)
        }
    }

    func hideErrorIfNil(field: Field) {
        guard let viewModel = viewModel else { return }
        
        if let input = input(for: field) {
            let error = viewModel.error(for: field, validate: input.text)
            if error == nil {
                input.error = nil
            }
        }
    }

    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    func onTextChanged(field: Field) {
        updateSubmitButtonState()
        hideErrorIfNil(field: field)
    }

    func onEndEditing(field: Field) {
        updateError(for: field)
    }

    func onBeginEditing(field: Field) {
        switch field {
        default: return
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
            requestToken()
        } else {
            showAllErrors()
            goToFirstInvalidField()
        }
    }

    func goToFirstInvalidField() {
        guard let viewModel = viewModel else { return }
        for field in viewModel.addressFields {
            if let input = input(for: field), input.error != nil {
                input.becomeFirstResponder()
                return
            }
        }

    }

    func showAllErrors() {
        guard let viewModel = viewModel else { return }
        for field in viewModel.addressFields {
            updateError(for: field)
        }
    }

}

extension CreditCardPaymentController {
    func updateInputAccessoryViewWithFirstResponder(_ firstResponder: OmiseTextField) {
        guard formFields.contains(firstResponder) else { return }

        currentEditingTextField = firstResponder
        gotoPreviousFieldBarButtonItem.isEnabled = firstResponder !== formFields.first
        gotoNextFieldBarButtonItem.isEnabled = firstResponder !== formFields.last
    }

    func gotoPreviousField() {
        guard let currentTextField = currentEditingTextField, let index = formFields.firstIndex(of: currentTextField) else {
            return
        }

        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        formFields[prevIndex].becomeFirstResponder()
    }

    func gotoNextField() {
        guard let currentTextField = currentEditingTextField, let index = formFields.firstIndex(of: currentTextField) else {
            return
        }

        let nextIndex = index + 1
        guard nextIndex < formFields.count else { return }
        formFields[nextIndex].becomeFirstResponder()
    }

    func doneEditing() {
        view.endEditing(true)
    }
}
