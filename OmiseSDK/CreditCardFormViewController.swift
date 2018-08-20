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

@available(*, deprecated,
message: "This delegate name is deprecated. Please use the new name of `OMSCreditCardFormViewControllerDelegate`",
renamed: "OMSCreditCardFormViewControllerDelegate")
@objc public protocol OMSCreditCardFormDelegate: OMSCreditCardFormViewControllerDelegate {}


@objc(OMSCreditCardFormViewControllerDelegate)
public protocol OMSCreditCardFormViewControllerDelegate: AnyObject {
    /// Delegate method for receiving token data when card tokenization succeeds.
    /// - parameter token: `OmiseToken` instance created from supplied credit card data.
    /// - seealso: [Tokens API](https://www.omise.co/tokens-api)
    @objc func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: __OmiseToken)
    
    /// Delegate method for receiving error information when card tokenization failed.
    /// This allows you to have fine-grained control over error handling when setting
    /// `handleErrors` to `false`.
    /// - parameter error: The error that occurred during tokenization.
    /// - note: This delegate method will *never* be called if `handleErrors` property is set to `true`.
    @objc func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: NSError)
    
    @objc optional func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController)
    
    @available(*, unavailable,
    message: "Implement the new -[OMSCreditCardFormViewControllerDelegate creditCardFormViewController:didSucceedWithToken:] instead",
    renamed: "creditCardFormViewController(_:didSucceedWithToken:)")
    @objc func creditCardForm(_ controller: CreditCardFormViewController, didSucceedWithToken token: __OmiseToken)
    
    @available(*, unavailable,
    message: "Implement the new -[OMSCreditCardFormViewControllerDelegate creditCardFormViewController:didFailWithError:] instead",
    renamed: "creditCardFormViewController(_:didFailWithError:)")
    @objc func creditCardForm(_ controller: CreditCardFormViewController, didFailWithError error: NSError)
}


@available(*, deprecated, renamed: "CreditCardFormViewController")
public typealias CreditCardFormController = CreditCardFormViewController


/// Drop-in credit card input form view controller that automatically tokenizes credit
/// card information.
@objc(OMSCreditCardFormViewController)
public class CreditCardFormViewController: UIViewController {
    private var hasErrorMessage = false
    
    @objc public static let defaultErrorMessageTextColor = UIColor(red: 1.000, green: 0.255, blue: 0.208, alpha: 1.0)
    
    @IBOutlet var formFields: [OmiseTextField]!
    @IBOutlet var formLabels: [UILabel]!
    @IBOutlet var errorLabels: [UILabel]!
  
    @IBOutlet var cardNumberTextField: CardNumberTextField!
    @IBOutlet var cardNameTextField: CardNameTextField!
    @IBOutlet var expiryDateTextField: CardExpiryDateTextField!
    @IBOutlet var secureCodeTextField: CardCVVTextField!
    
    @IBOutlet weak var confirmButton: MainActionButton!
    
    @IBOutlet var formFieldsAccessoryView: UIToolbar!
    @IBOutlet var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var gotoNextFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneEditingBarButtonItem: UIBarButtonItem!
    
    private var currentEditingTextField: OmiseTextField?
    
    @IBOutlet weak var creditCardNumberErrorLabel: UILabel!
    @IBOutlet weak var cardHolderNameErrorLabel: UILabel!
    @IBOutlet weak var cardExpiryDateErrorLabel: UILabel!
    @IBOutlet weak var cardSecurityCodeErrorLabel: UILabel!
    
    @IBOutlet var processingErrorBannerView: UIView!
    @IBOutlet var processingErrorLabel: UILabel!
    @IBOutlet var hidingProcessingErrorBannerConstraint: NSLayoutConstraint!
    
    /// Omise public key for calling tokenization API.
    @objc public var publicKey: String?
    
    /// Delegate to receive CreditCardFormController result.
    public weak var delegate: CreditCardFormViewControllerDelegate?
    @objc(delegate) public weak var __delegate: OMSCreditCardFormViewControllerDelegate?
    
    /// A boolean flag to enables/disables automatic error handling. Defaults to `true`.
    @objc public var handleErrors = true
    
    var isInputDataValid: Bool {
        return formFields.reduce(into: true, { (valid, field) in
            valid = valid && field.isValid
        })
    }
    
    @IBInspectable @objc
    public var errorMessageTextColor: UIColor! = CreditCardFormViewController.defaultErrorMessageTextColor {
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
    
    /// A boolean flag that enables/disables Card.IO integration.
    @available(*, unavailable, message: "Built in support for Card.ios was removed. You can implement it in your app and call the setCreditCardInformation(number:name:expiration:) method")
    @objc public var cardIOEnabled: Bool = true
    
    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    @objc(creditCardFormViewControllerWithPublicKey:)
    public static func makeCreditCardFormViewController(withPublicKey publicKey: String) -> CreditCardFormViewController {
        let omiseBundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: omiseBundle)
        let creditCardForm = storyboard.instantiateInitialViewController() as! CreditCardFormViewController
        creditCardForm.publicKey = publicKey
        
        return creditCardForm
    }
    
    @available(*, deprecated,
    message: "Please use the new method that confrom to Objective-C convention +[OMSCreditCardFormViewController creditCardFormViewControllerWithPublicKey:] as of this method will be removed in the future release.",
    renamed: "makeCreditCardFormViewController(withPublicKey:)")
    @objc(makeCreditCardFormWithPublicKey:) public static func __makeCreditCardForm(withPublicKey publicKey: String) -> CreditCardFormViewController {
        return CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        formFields.forEach({
            $0.inputAccessoryView = formFieldsAccessoryView
        })
        
        errorLabels.forEach({
            $0.textColor = errorMessageTextColor
        })
        
        formFields.forEach(self.updateAccessibilityValue)
        
        updateSupplementaryUI()
        
        if #available(iOS 10.0, *) {
            configureAccessibility()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self, selector:#selector(keyboardWillAppear(_:)),
            name: NSNotification.Name.UIKeyboardWillShow, object: nil
        )
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter().removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    public func setCreditCardInformationWith(number: String?, name: String?, expiration: (month: Int, year: Int)?) {
        cardNumberTextField.text = number
        cardNameTextField.text = name

        if let expiration = expiration, 1...12 ~= expiration.month, expiration.year > 0 {
            expiryDateTextField.text = String(format: "%02d/%d", expiration.month, expiration.year - 2000)
        }
        
        updateSupplementaryUI()
        
        if #available(iOS 10.0, *) {
            os_log("The custom credit card information was set - %{private}@",
                   log: uiLogObject, type: .debug, String((number ?? "").suffix(4)))
        }
    }
    
    @objc(setCreditCardInformationWithNumber:name:expirationMonth:expirationYear:)
    public func __setCreditCardInformation(number: String, name: String, expirationMonth: Int, expirationYear: Int) {
        let month: Int?
        let year: Int?
        if 1...12 ~= expirationMonth {
            month = expirationMonth
        } else {
            month = nil
        }
        
        if expirationYear > 0 && expirationYear != NSNotFound {
            year = expirationYear
        } else {
            year = nil
        }
        
        let expiration: (month: Int, year: Int)?
        if let month = month, let year = year {
            expiration = (month: month, year: year)
        } else {
            expiration = nil
        }

        self.setCreditCardInformationWith(number: number, name: name, expiration: expiration)
    }
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        if hasErrorMessage {
            hasErrorMessage = false
        }
    }
    
    @IBAction func cancelForm() {
        performCancelingForm()
    }
    
    @discardableResult
    private func performCancelingForm() -> Bool {
        if #available(iOS 10.0, *) {
            os_log("Credit Card Form dismissing requested, Asking the delegate what should the form controler do",
                   log: uiLogObject, type: .default)
        }
        
        if let delegate = self.delegate {
            delegate.creditCardFormViewControllerDidCancel(self)
            if #available(iOS 10.0, *) {
                os_log("Canceling form delegate notified", log: uiLogObject, type: .default)
            }
            return true
        } else if let delegateMethod = __delegate?.creditCardFormViewControllerDidCancel {
            delegateMethod(self)
            if #available(iOS 10.0, *) {
                os_log("Canceling form delegate notified", log: uiLogObject, type: .default)
            }
            return true
        } else {
            if #available(iOS 10.0, *) {
                os_log("Credit Card Form dismissing requested but there is not delegate to ask. Ignore the request",
                       log: uiLogObject, type: .default)
            }
            return false
        }
    }
    
    private func handleError(_ error: Error) {
        guard handleErrors else {
            if #available(iOS 10.0, *) {
                os_log("Credit Card Form's Request failed %{private}@, automatically error handling turned off. Trying to notify the delegate", log: uiLogObject, type: .info, error.localizedDescription)
            }
            if let delegate = self.delegate {
                delegate.creditCardFormViewController(self, didFailWithError: error)
                if #available(iOS 10.0, *) {
                    os_log("Error handling delegate notified", log: uiLogObject, type: .default)
                }
            } else if let delegate = self.__delegate {
                delegate.creditCardFormViewController(self, didFailWithError: error as NSError)
                if #available(iOS 10.0, *) {
                    os_log("Error handling delegate notified", log: uiLogObject, type: .default)
                }
            } else if #available(iOS 10.0, *) {
                os_log("There is no Credit Card Form's delegate to notify about the error", log: uiLogObject, type: .info)
            }
            return
        }
        
        if #available(iOS 10.0, *) {
            os_log("Credit Card Form's Request failed %{private}@, automatically error handling turned on.", log: uiLogObject, type: .info, error.localizedDescription)
        }
        
        hasErrorMessage = true
        processingErrorLabel.text = error.localizedDescription
        //TODO: Animate the error banner
    }
    
    private func updateSupplementaryUI() {
        let valid = isInputDataValid
        confirmButton?.isEnabled = valid
        if valid {
            confirmButton.accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
        } else {
            confirmButton.accessibilityTraits |= UIAccessibilityTraitNotEnabled
        }
    }
    
    @IBAction private func requestToken() {
        doneEditing(nil)
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Submitting payment, please wait")
        
        guard let publicKey = publicKey else {
            if #available(iOS 10.0, *) {
                os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
            }
            assertionFailure("Missing public key information. Please setting the public key before request token.")
            return
        }
        
        if #available(iOS 10.0, *) {
            os_log("Requesting token", log: uiLogObject, type: .info)
        }
        
        startActivityIndicator()
        let request = Request<Token>(
            name: cardNameTextField.text ?? "",
            pan: cardNumberTextField.pan,
            expirationMonth: expiryDateTextField.selectedMonth ?? 0,
            expirationYear: expiryDateTextField.selectedYear ?? 0,
            securityCode: secureCodeTextField.text ?? ""
        )
        
        let client = Client(publicKey: publicKey)
        client.sendRequest(request, completionHandler: { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            strongSelf.stopActivityIndicator()
            switch result {
            case let .success(token):
                if #available(iOS 10.0, *) {
                    os_log("Credit Card Form's Request succeed %{private}@, trying to notify the delegate", log: uiLogObject, type: .default, token.id)
                }
                if let delegate = strongSelf.delegate {
                    delegate.creditCardFormViewController(strongSelf, didSucceedWithToken: token)
                    if #available(iOS 10.0, *) {
                        os_log("Create Token succeed delegate notified", log: uiLogObject, type: .default)
                    }
                } else if let delegate = strongSelf.__delegate {
                    delegate.creditCardFormViewController(strongSelf, didSucceedWithToken: __OmiseToken(token: token))
                    if #available(iOS 10.0, *) {
                        os_log("Create Token succeed delegate notified", log: uiLogObject, type: .default)
                    }
                } else if #available(iOS 10.0, *) {
                    os_log("There is no Credit Card Form's delegate to notify about the created token", log: uiLogObject, type: .default)
                }
            case let .fail(err):
                strongSelf.handleError(err)
            }
        })
    }
    
    private func startActivityIndicator() {
        view.isUserInteractionEnabled = false
    }
    
    private func stopActivityIndicator() {
        view.isUserInteractionEnabled = true
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
            case (OmiseTextFieldValidationError.emptyText, cardNumberTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.card-number-field.empty-text.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "Credit card number cannot be empty",
                    comment: "An error text displayed when the credit card number is empty"
                )
            case (OmiseTextFieldValidationError.emptyText, cardNameTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.card-holder-name-field.empty-text.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "Card holder name cannot be empty",
                    comment: "An error text displayed when the card holder name is empty"
                )
            case (OmiseTextFieldValidationError.emptyText, expiryDateTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.expiry-date-field.empty-text.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "Card expiry date cannot be empty",
                    comment: "An error text displayed when the expiry date is empty"
                )
            case (OmiseTextFieldValidationError.emptyText, secureCodeTextField):
                errorLabel.text = NSLocalizedString(
                    "credit-card-form.security-code-field.empty-text.error.text", tableName: "Error", bundle: omiseBundle,
                    value: "CVV code cannot be empty",
                    comment: "An error text displayed when the security code is empty"
                )
                
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
                break
            }
            errorLabel.alpha = 1.0
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 10.0, *) {
            if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                view.setNeedsUpdateConstraints()
            }
        }
    }
}


// MARK: - Fields Accessory methods
extension CreditCardFormViewController {
    
    @IBAction func validateTextFieldDataOf(_ sender: OmiseTextField) {
        let duration = TimeInterval(UINavigationControllerHideShowBarDuration)
        UIView.animate(
            withDuration: duration, delay: 0.0,
            options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews],
            animations: {
                self.validateField(sender)
        })
    }
    
    @IBAction func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
        if let errorLabel = associatedErrorLabelOf(sender) {
            let duration = TimeInterval(UINavigationControllerHideShowBarDuration)
            UIView.animate(
                withDuration: duration, delay: 0.0,
                options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews],
                animations: {
                    errorLabel.alpha = 0.0
            })
        }
        
        guard formFields.contains(sender) else { return }
        
        currentEditingTextField = sender
        gotoPreviousFieldBarButtonItem.isEnabled = sender !== formFields.first
        gotoNextFieldBarButtonItem.isEnabled = sender !== formFields.last
    }
    
    @objc @IBAction private func gotoPreviousField(_ button: UIBarButtonItem) {
        guard let currentTextField = currentEditingTextField, let index = formFields.index(of: currentTextField) else {
            return
        }

        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        formFields[prevIndex].becomeFirstResponder()
    }
    
    @objc @IBAction private func gotoNextField(_ button: UIBarButtonItem) {
        guard let currentTextField = currentEditingTextField, let index = formFields.index(of: currentTextField) else {
            return
        }

        let nextIndex = index + 1
        guard nextIndex < formFields.count else { return }
        formFields[nextIndex].becomeFirstResponder()
    }
    
    @objc @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        view.endEditing(true)
    }
}


// MARK: - Accessibility
extension CreditCardFormViewController {
    
    @IBAction func updateAccessibilityValue(_ sender: OmiseTextField) {
        updateSupplementaryUI()
    }
    
    @available(iOS 10, *)
    private func configureAccessibility() {
        formLabels.forEach({
            $0.adjustsFontForContentSizeCategory = true
        })
        formFields.forEach({
            $0.adjustsFontForContentSizeCategory = true
        })
        
        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        let fieldsAccessibilityElements = ([
            cardNumberTextField.accessibilityElements?.first ?? cardNumberTextField,
            cardNameTextField.accessibilityElements?.first ?? cardNameTextField,
            expiryDateTextField.expirationMonthAccessibilityElement,
            expiryDateTextField.expirationYearAccessibilityElement,
            secureCodeTextField.accessibilityElements?.first ?? secureCodeTextField,
            ]).compactMap({ $0 as? NSObjectProtocol })
        
        let fields = [
            cardNumberTextField,
            cardNameTextField,
            expiryDateTextField,
            secureCodeTextField,
            ] as [OmiseTextField]
        
        func accessiblityElementAfter(_ element: NSObjectProtocol?,
                                      matchingPredicate predicate: (OmiseTextField) -> Bool,
                                      direction: UIAccessibilityCustomRotorDirection) -> NSObjectProtocol? {
            guard let element = element else {
                switch direction {
                case .next:
                    return fields.first(where: predicate)?.accessibilityElements?.first as? NSObjectProtocol ?? fields.first(where: predicate)
                case .previous:
                    return fields.reversed().first(where: predicate)?.accessibilityElements?.last as? NSObjectProtocol ?? fields.reversed().first(where: predicate)
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
                            direction: UIAccessibilityCustomRotorDirection) -> OmiseTextField? {
                guard let indexOfField = fields.index(of: field) else { return nil }
                switch direction {
                case .next:
                    return fields[fields.index(after: indexOfField)...].first(where: predicate)
                case .previous:
                    return fields[fields.startIndex..<indexOfField].reversed().first(where: predicate)
                }
            }
            
            let nextField = filedAfter(fieldOfElement, matchingPredicate: predicate, direction: direction)
            
            guard let currentAccessibilityElements = (fieldOfElement.accessibilityElements as? [NSObjectProtocol]),
                let indexOfAccessibilityElement = currentAccessibilityElements.index(where: { $0 === element }) else {
                    switch direction {
                    case .next:
                        return nextField?.accessibilityElements?.first as? NSObjectProtocol ?? nextField
                    case .previous:
                        return nextField?.accessibilityElements?.last as? NSObjectProtocol ?? nextField
                    }
            }
            
            switch direction {
            case .next:
                if predicate(fieldOfElement) && indexOfAccessibilityElement < currentAccessibilityElements.endIndex - 1 {
                    return currentAccessibilityElements[currentAccessibilityElements.index(after: indexOfAccessibilityElement)]
                } else {
                    return nextField?.accessibilityElements?.first as? NSObjectProtocol ?? nextField
                }
            case .previous:
                if predicate(fieldOfElement) && indexOfAccessibilityElement > currentAccessibilityElements.startIndex {
                    return currentAccessibilityElements[currentAccessibilityElements.index(before: indexOfAccessibilityElement)]
                } else {
                    return nextField?.accessibilityElements?.last as? NSObjectProtocol ?? nextField
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

