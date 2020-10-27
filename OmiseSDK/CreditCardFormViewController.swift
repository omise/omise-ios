import UIKit
import os.log


public protocol CreditCardFormViewControllerDelegate: AnyObject {
    /// Delegate method for receiving token data when card tokenization succeeds.
    /// - parameter token: `OmiseToken` instance created from supplied credit card data.
    /// - seealso: [Tokens API](https://www.omise.co/tokens-api)
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token)
    
    /// Delegate method for receiving error information when card tokenization failed.
    /// This allows you to have fine-grained control over error handling when setting
    /// `handleErrors` to `false`.
    /// - parameter error: The error that occurred during tokenization.
    /// - note: This delegate method will *never* be called if `handleErrors` property is set to `true`.
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error)
    
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController)
}


/// Delegate to receive card tokenization events.
@available(*, deprecated, renamed: "CreditCardFormViewControllerDelegate")
public typealias CreditCardFormControllerDelegate = CreditCardFormViewControllerDelegate

@available(*, unavailable, renamed: "CreditCardFormViewControllerDelegate")
public protocol CreditCardFormDelegate: CreditCardFormViewControllerDelegate {
    
    @available(*, deprecated,
    renamed: "CreditCardFormViewControllerDelegate.creditCardFormViewController(_:didSucceedWithToken:)")
    func creditCardForm(_ controller: CreditCardFormController, didSucceedWithToken token: Token)
    
    @available(*, deprecated,
    renamed: "CreditCardFormViewControllerDelegate.creditCardFormViewController(_:didFailWithError:)")
    func creditCardForm(_ controller: CreditCardFormController, didFailWithError error: Error)
}

@available(*, deprecated, renamed: "CreditCardFormViewController")
public typealias CreditCardFormController = CreditCardFormViewController


/// Drop-in credit card input form view controller that automatically tokenizes credit
/// card information.
public class CreditCardFormViewController: UIViewController, PaymentChooserUI, PaymentFormUIController {
    
    /// Omise public key for calling tokenization API.
    public var publicKey: String?
    
    /// Delegate to receive CreditCardFormController result.
    public weak var delegate: CreditCardFormViewControllerDelegate?
    
    /// A boolean flag to enables/disables automatic error handling. Defaults to `true`.
    public var handleErrors = true
    
    @IBInspectable public var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    @IBInspectable public var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }

    @IBInspectable public var errorMessageTextColor: UIColor! = CreditCardFormViewController.defaultErrorMessageTextColor {
        didSet {
            if errorMessageTextColor == nil {
                errorMessageTextColor = CreditCardFormViewController.defaultErrorMessageTextColor
            }
            
            if isViewLoaded {
                errorLabels.forEach({
                    $0.textColor = errorMessageTextColor
                })
            }
        }
    }
    
    private lazy var overlayTransitionDelegate = OverlayPanelTransitioningDelegate()
    
    var isInputDataValid: Bool {
        return formFields.reduce(into: true, { (valid, field) in
            valid = valid && field.isValid
        })
    }
    
    var currentEditingTextField: OmiseTextField?
    private var hasErrorMessage = false
    
    
    @IBOutlet var formFields: [OmiseTextField]!
    @IBOutlet var formLabels: [UILabel]!
    @IBOutlet var errorLabels: [UILabel]!
  
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet var cardNumberTextField: CardNumberTextField!
    @IBOutlet var cardNameTextField: CardNameTextField!
    @IBOutlet var expiryDateTextField: CardExpiryDateTextField!
    @IBOutlet var secureCodeTextField: CardCVVTextField!
    
    @IBOutlet var confirmButton: MainActionButton!
    
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
    
    @IBOutlet var requestingIndicatorView: UIActivityIndicatorView!
    public static let defaultErrorMessageTextColor = UIColor.error


    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    public static func makeCreditCardFormViewController(withPublicKey publicKey: String) -> CreditCardFormViewController {
        let omiseBundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: omiseBundle)
        let creditCardForm = storyboard.instantiateInitialViewController() as! CreditCardFormViewController
        creditCardForm.publicKey = publicKey
        
        return creditCardForm
    }

    public func setCreditCardInformationWith(number: String?, name: String?, expiration: (month: Int, year: Int)?) {
        cardNumberTextField.text = number
        cardNameTextField.text = name
        
        if let expiration = expiration, 1...12 ~= expiration.month, expiration.year > 0 {
            expiryDateTextField.text = String(format: "%02d/%d", expiration.month, expiration.year % 100)
        }
        
        updateSupplementaryUI()
        
        os_log("The custom credit card information was set - %{private}@",
               log: uiLogObject, type: .debug, String((number ?? "").suffix(4)))
    }

    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.background
        confirmButton.defaultBackgroundColor = view.tintColor
        confirmButton.disabledBackgroundColor = .line
        
        cvvInfoButton.tintColor = .badgeBackground
        formFieldsAccessoryView.barTintColor = .formAccessoryBarTintColor
        
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            let appearance = navigationItem.standardAppearance ?? UINavigationBarAppearance(idiom: .phone)
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            appearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            let image = renderer.image { (context) in
                context.cgContext.setFillColor(UIColor.line.cgColor)
                context.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
            }
            appearance.shadowImage = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
                .withRenderingMode(.alwaysTemplate)
            appearance.shadowColor = preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
            navigationItem.standardAppearance = appearance
            
            let scrollEdgeAppearance = appearance.copy()
            appearance.shadowColor = preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
            navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
        }
        #endif
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        applyPrimaryColor()
        applySecondaryColor()
        
        formFields.forEach({
            $0.inputAccessoryView = formFieldsAccessoryView
        })
        
        errorLabels.forEach({
            $0.textColor = errorMessageTextColor
        })
        
        formFields.forEach(self.updateAccessibilityValue)
        
        updateSupplementaryUI()
        
        configureAccessibility()
        formFields.forEach({
            $0.adjustsFontForContentSizeCategory = true
        })
        formLabels.forEach({
            $0.adjustsFontForContentSizeCategory = true
        })
        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true

        cardNumberTextField.rightView = cardBrandIconImageView
        secureCodeTextField.rightView = cvvInfoButton
        secureCodeTextField.rightViewMode = .always
        
        NotificationCenter.default.addObserver(
            self, selector:#selector(keyboardWillChangeFrame(_:)),
            name: NotificationKeyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector:#selector(keyboardWillHide(_:)),
            name: NotificationKeyboardWillHideFrameNotification, object: nil
        )
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self, selector:#selector(keyboardWillAppear(_:)),
            name: NotificationKeyboardWillShowFrameNotification, object: nil
        )
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter().removeObserver(self, name: NotificationKeyboardWillShowFrameNotification, object: nil)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            view.setNeedsUpdateConstraints()
        }
    }
    
    @IBAction func displayMoreCVVInfo(_ sender: UIButton) {
        guard let moreInformationOnCVVViewController = storyboard?.instantiateViewController(withIdentifier: "MoreInformationOnCVVViewController") as? MoreInformationOnCVVViewController else {
            return
        }
        
        moreInformationOnCVVViewController.preferredCardBrand = cardNumberTextField.cardBrand
        moreInformationOnCVVViewController.delegate = self
        moreInformationOnCVVViewController.modalPresentationStyle = .custom
        moreInformationOnCVVViewController.transitioningDelegate = overlayTransitionDelegate
        moreInformationOnCVVViewController.view.tintColor = view.tintColor
        present(moreInformationOnCVVViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelForm() {
        performCancelingForm()
    }
    
    @discardableResult
    private func performCancelingForm() -> Bool {
        os_log("Credit Card Form dismissing requested, Asking the delegate what should the form controler do",
               log: uiLogObject, type: .default)
        
        if let delegate = self.delegate {
            delegate.creditCardFormViewControllerDidCancel(self)
            os_log("Canceling form delegate notified", log: uiLogObject, type: .default)
            return true
        } else {
            os_log("Credit Card Form dismissing requested but there is not delegate to ask. Ignore the request",
                   log: uiLogObject, type: .default)
            return false
        }
    }
    
    @IBAction private func requestToken() {
        doneEditing(nil)
        
        UIAccessibility.post(notification: AccessibilityNotificationAnnouncement, argument: "Submitting payment, please wait")
        
        guard let publicKey = publicKey else {
            os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
            assertionFailure("Missing public key information. Please set the public key before request token.")
            return
        }
        
        os_log("Requesting to create token", log: uiLogObject, type: .info)
        
        startActivityIndicator()
        let request = Request<Token>(
            name: cardNameTextField.text ?? "",
            pan: cardNumberTextField.pan,
            expirationMonth: expiryDateTextField.selectedMonth ?? 0,
            expirationYear: expiryDateTextField.selectedYear ?? 0,
            securityCode: secureCodeTextField.text ?? ""
        )
        
        let client = Client(publicKey: publicKey)
        client.send(request, completionHandler: { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            strongSelf.stopActivityIndicator()
            switch result {
            case let .success(token):
                os_log("Credit Card Form's Request succeed %{private}@, trying to notify the delegate", log: uiLogObject, type: .default, token.id)
                if let delegate = strongSelf.delegate {
                    delegate.creditCardFormViewController(strongSelf, didSucceedWithToken: token)
                    os_log("Credit Card Form Create Token succeed delegate notified", log: uiLogObject, type: .default)
                } else {
                    os_log("There is no Credit Card Form's delegate to notify about the created token", log: uiLogObject, type: .default)
                }
            case let .failure(err):
                strongSelf.handleError(err)
            }
        })
    }
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        if hasErrorMessage {
            hasErrorMessage = false
            dismissErrorMessage(animated: true, sender: self)
        }
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
        bottomScrollIndicatorInset = intersectedFrame.height - contentView.safeAreaInsets.bottom
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        contentView.contentInset.bottom = 0.0
        contentView.scrollIndicatorInsets.bottom = 0.0
    }
    
    private func handleError(_ error: Error) {
        guard handleErrors else {
            os_log("Credit Card Form's Request failed %{private}@, automatically error handling turned off. Trying to notify the delegate", log: uiLogObject, type: .info, error.localizedDescription)
            if let delegate = self.delegate {
                delegate.creditCardFormViewController(self, didFailWithError: error)
                os_log("Error handling delegate notified", log: uiLogObject, type: .default)
            } else {
                os_log("There is no Credit Card Form's delegate to notify about the error", log: uiLogObject, type: .default)
            }
            return
        }
        
        os_log("Credit Card Form's Request failed %{private}@, automatically error handling turned on.", log: uiLogObject, type: .default, error.localizedDescription)
        
        displayError(error)
        hasErrorMessage = true
    }
    
    private func displayError(_ error: Error) {
        let targetController = targetViewController(forAction: #selector(UIViewController.displayErrorWith(title:message:animated:sender:)), sender: self)
        if let targetController = targetController, targetController !== self {
            if let error = error as? OmiseError {
                targetController.displayErrorWith(title: error.bannerErrorDescription, message: error.bannerErrorRecoverySuggestion, animated: true, sender: self)
            } else if let error = error as? LocalizedError {
                targetController.displayErrorWith(title: error.localizedDescription, message: error.recoverySuggestion, animated: true, sender: self)
            } else {
                targetController.displayErrorWith(title: error.localizedDescription, message: nil, animated: true, sender: self)
            }
        } else {
            let errorTitle: String
            let errorMessage: String?
            if let error = error as? OmiseError {
                errorTitle = error.bannerErrorDescription
                errorMessage = error.bannerErrorRecoverySuggestion
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
    
    private func setShowsErrorBanner(_ showsErrorBanner: Bool, animated: Bool = true) {
        hidingErrorBannerConstraint.isActive = !showsErrorBanner
        
        let animationBlock = {
            self.errorBannerView.alpha = showsErrorBanner ? 1.0 : 0.0
            self.contentView.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval(NavigationControllerHideShowBarDuration), delay: 0.0, options: [.layoutSubviews], animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    @IBAction func dismissErrorBanner(_ sender: Any) {
        setShowsErrorBanner(false)
    }
    
    private func updateSupplementaryUI() {
        let valid = isInputDataValid
        confirmButton?.isEnabled = valid
        
        if valid {
            confirmButton.accessibilityTraits.remove(UIAccessibilityTraits.notEnabled)
        } else {
            confirmButton.accessibilityTraits.insert(UIAccessibilityTraits.notEnabled)
        }
        
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
        cardBrandIconImageView.image = cardBrandIconName.flatMap({ UIImage(named: $0, in: Bundle.omiseSDKBundle, compatibleWith: nil) })
        cardNumberTextField.rightViewMode = cardBrandIconImageView.image != nil ? .always : .never
    }
    
    private func startActivityIndicator() {
        requestingIndicatorView.startAnimating()
        confirmButton.isEnabled = false
        view.isUserInteractionEnabled = false
    }
    
    private func stopActivityIndicator() {
        requestingIndicatorView.stopAnimating()
        confirmButton.isEnabled = true
        view.isUserInteractionEnabled = true
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        formFields.forEach({
            $0.textColor = currentPrimaryColor
        })
        formLabels.forEach({
            $0.textColor = currentPrimaryColor
        })
    }
    
    private func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        
        formFields.forEach({
            $0.borderColor = currentSecondaryColor
            $0.placeholderTextColor = currentSecondaryColor
        })
    }
    
    fileprivate func associatedErrorLabelOf(_ textField: OmiseTextField) -> UILabel? {
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
    
    private func validateField(_ textField: OmiseTextField) {
        guard let errorLabel = associatedErrorLabelOf(textField) else {
            return
        }
        do {
            try textField.validate()
            errorLabel.alpha = 0.0
        } catch {
            let omiseBundle = Bundle(for: CreditCardFormViewController.self)
            switch (error, textField) {
            case (OmiseTextFieldValidationError.emptyText, _):
                errorLabel.text = "-" // We need to set the error label some string in order to have it retains its height
                
            case (OmiseTextFieldValidationError.invalidData, cardNumberTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.card-number-field.invalid-data.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "Credit card number is invalid",
                    comment: "An error text displayed when the credit card number is invalid"
                )
            case (OmiseTextFieldValidationError.invalidData, cardNameTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.card-holder-name-field.invalid-data.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "Card holder name is invalid",
                    comment: "An error text displayed when the card holder name is invalid"
                )
            case (OmiseTextFieldValidationError.invalidData, expiryDateTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.expiry-date-field.invalid-data.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "Card expiry date is invalid",
                    comment: "An error text displayed when the expiry date is invalid"
                )
            case (OmiseTextFieldValidationError.invalidData, secureCodeTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.security-code-field.invalid-data.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "CVV code is invalid",
                    comment: "An error text displayed when the security code is invalid"
                )
                
            case (_, cardNumberTextField):
                errorLabel.text = error.localizedDescription
            case (_, cardNameTextField):
                errorLabel.text = error.localizedDescription
            case (_, expiryDateTextField):
                errorLabel.text = error.localizedDescription
            case (_, secureCodeTextField):
                errorLabel.text = error.localizedDescription
            default:
                errorLabel.text = "-"
            }
            errorLabel.alpha = errorLabel.text != "-" ? 1.0 : 0.0
        }
    }
}


// MARK: - Fields Accessory methods
extension CreditCardFormViewController {
    
    @IBAction func validateTextFieldDataOf(_ sender: OmiseTextField) {
        let duration = TimeInterval(NavigationControllerHideShowBarDuration)
        UIView.animate(
            withDuration: duration, delay: 0.0,
            options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews],
            animations: {
                self.validateField(sender)
        })
        sender.borderColor = currentSecondaryColor
    }
    
    @IBAction func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
        if let errorLabel = associatedErrorLabelOf(sender) {
            let duration = TimeInterval(NavigationControllerHideShowBarDuration)
            UIView.animate(
                withDuration: duration, delay: 0.0,
                options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews],
                animations: {
                    errorLabel.alpha = 0.0
            })
        }
        
        sender.borderColor = view.tintColor
        updateInputAccessoryViewWithFirstResponder(sender)
    }
    
    @objc @IBAction private func gotoPreviousField(_ button: UIBarButtonItem) {
        gotoPreviousField()
    }
    
    @objc @IBAction private func gotoNextField(_ button: UIBarButtonItem) {
        gotoNextField()
    }
    
    @objc @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }
}


// MARK: - Accessibility
extension CreditCardFormViewController {
    
    @IBAction func updateAccessibilityValue(_ sender: OmiseTextField) {
        updateSupplementaryUI()
    }
    
    private func configureAccessibility() {
        formLabels.forEach({
            $0.adjustsFontForContentSizeCategory = true
        })
        formFields.forEach({
            $0.adjustsFontForContentSizeCategory = true
        })
        
        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        let fields = [
            cardNumberTextField,
            cardNameTextField,
            expiryDateTextField,
            secureCodeTextField,
            ] as [OmiseTextField]
        
        func accessiblityElementAfter(_ element: NSObjectProtocol?,
                                      matchingPredicate predicate: (OmiseTextField) -> Bool,
                                      direction: AccessibilityCustomRotorDirection) -> NSObjectProtocol? {
            guard let element = element else {
                switch direction {
                case .previous:
                    return fields.reversed().first(where: predicate)?.accessibilityElements?.last as? NSObjectProtocol ?? fields.reversed().first(where: predicate)
                case .next:
                    fallthrough
                @unknown default:
                    return fields.first(where: predicate)?.accessibilityElements?.first as? NSObjectProtocol ?? fields.first(where: predicate)
                }
            }
            
            let fieldOfElement = fields.first(where: { field in
                guard let accessibilityElements = field.accessibilityElements as? [NSObjectProtocol] else {
                    return element === field
                }
                
                return accessibilityElements.contains(where: { $0 === element })
            }) ?? cardNumberTextField!
            
            func filedAfter(_ field: OmiseTextField,
                            matchingPredicate predicate: (OmiseTextField) -> Bool,
                            direction: AccessibilityCustomRotorDirection) -> OmiseTextField? {
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
            UIAccessibilityCustomRotor(name: "Fields", itemSearch: { (predicate) -> UIAccessibilityCustomRotorItemResult? in
                return accessiblityElementAfter(predicate.currentItem.targetElement, matchingPredicate: { _ in true }, direction: predicate.searchDirection)
                    .map({ UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) })
            }),
            UIAccessibilityCustomRotor(name: "Invalid Data Fields", itemSearch: { (predicate) -> UIAccessibilityCustomRotorItemResult? in
                return accessiblityElementAfter(predicate.currentItem.targetElement, matchingPredicate: { !$0.isValid }, direction: predicate.searchDirection)
                    .map({ UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) })
            }),
        ]
    }
    
    public override func accessibilityPerformMagicTap() -> Bool {
        guard isInputDataValid else {
            return false
        }
        
        requestToken()
        return true
    }
    
    public override func accessibilityPerformEscape() -> Bool {
        return performCancelingForm()
    }
}


extension CreditCardFormViewController: MoreInformationOnCVVViewControllerDelegate {
    func moreInformationOnCVVViewControllerDidAskToClose(_ controller: MoreInformationOnCVVViewController) {
        dismiss(animated: true, completion: nil)
    }
}

