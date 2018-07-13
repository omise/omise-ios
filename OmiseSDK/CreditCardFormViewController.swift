import UIKit


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
public class CreditCardFormViewController: UITableViewController {
    private var hasErrorMessage = false
    
    @objc public static let defaultErrorMessageTextColor = UIColor(red: 1.000, green: 0.255, blue: 0.208, alpha: 1.0)
    
    @IBOutlet var formHeaderView: FormHeaderView!
    @IBOutlet var formFields: [OmiseTextField]!
    
    @IBOutlet var formCells: [UITableViewCell]!
    
    @IBOutlet var formLabels: [UILabel]!
    @IBOutlet var labelWidthConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var cardNumberCell: CardNumberFormCell!
    @IBOutlet var cardNumberTextField: CardNumberTextField!
    @IBOutlet var cardNameCell: NameCardFormCell!
    @IBOutlet var cardNameTextField: CardNameTextField!
    @IBOutlet var expiryDateCell: ExpiryDateFormCell!
    @IBOutlet var expiryDateTextField: CardExpiryDateTextField!
    @IBOutlet var secureCodeCell: SecureCodeFormCell!
    @IBOutlet var secureCodeTextField: CardCVVTextField!
    @IBOutlet var confirmButtonCell: ConfirmButtonCell!
    
    @IBOutlet var errorMessageView: ErrorMessageView!
    
    @IBOutlet var formFieldsAccessoryView: UIToolbar!
    @IBOutlet var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var gotoNextFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneEditingBarButtonItem: UIBarButtonItem!
    
    private var currentEditingTextField: OmiseTextField?
    
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
                errorMessageView.errorMessageLabel.textColor = errorMessageTextColor
                cardNumberTextField.errorTextColor = errorMessageTextColor
                cardNameTextField.errorTextColor = errorMessageTextColor
                expiryDateTextField.errorTextColor = errorMessageTextColor
                secureCodeTextField.errorTextColor = errorMessageTextColor
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
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        
        updateLabelWidthConstraints()
        
        errorMessageView.errorMessageLabel.textColor = errorMessageTextColor
        cardNumberTextField.errorTextColor = errorMessageTextColor
        cardNameTextField.errorTextColor = errorMessageTextColor
        expiryDateTextField.errorTextColor = errorMessageTextColor
        secureCodeTextField.errorTextColor = errorMessageTextColor
        
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
            errorMessageView?.removeErrorMesssage()
            hasErrorMessage = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    @IBAction func cancelForm() {
        _ = performCancelingForm()
    }
    
    private func performCancelingForm() -> Bool {
        if let delegate = self.delegate {
            delegate.creditCardFormViewControllerDidCancel(self)
            return true
        } else if let delegate = __delegate?.creditCardFormViewControllerDidCancel {
            delegate(self)
            return true
        } else {
            return false
        }
    }
    
    private func handleError(_ error: Error) {
        guard handleErrors else {
            if let delegate = self.delegate {
                delegate.creditCardFormViewController(self, didFailWithError: error)
            } else {
                __delegate?.creditCardFormViewController(self, didFailWithError: error as NSError)
            }
            return
        }
        
        let errorString: String
        switch error {
        case let error as OmiseError:
            errorString = error.localizedDescription
        default:
            errorString = (error as NSError).localizedDescription
        }
        
        errorMessageView?.setErrorMessage(errorString)
        hasErrorMessage = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func updateSupplementaryUI() {
        let valid = isInputDataValid
        confirmButtonCell?.isUserInteractionEnabled = valid
        confirmButtonCell.tintAdjustmentMode = valid ? .automatic : .dimmed
        if valid {
            confirmButtonCell.accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
        } else {
            confirmButtonCell.accessibilityTraits |= UIAccessibilityTraitNotEnabled
        }
        
        formHeaderView?.setCardBrand(cardNumberTextField.cardBrand)
    }
    
    private func requestToken() {
        doneEditing(nil)
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Submitting payment, please wait")
        
        guard let publicKey = publicKey else {
            assertionFailure("Missing public key information. Please setting the public key before request token.")
            return
        }
        
        startActivityIndicator()
        let request = Request<Token>(
            name: cardNameCell?.value ?? "",
            pan: cardNumberCell.value,
            expirationMonth: expiryDateCell?.month ?? 0,
            expirationYear: expiryDateCell?.year ?? 0,
            securityCode: secureCodeCell?.value ?? ""
        )
        
        let client = Client(publicKey: publicKey)
        client.sendRequest(request, completionHandler: { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            strongSelf.stopActivityIndicator()
            switch result {
            case let .success(token):
                if let delegate = strongSelf.delegate {
                    delegate.creditCardFormViewController(strongSelf, didSucceedWithToken: token)
                } else {
                    strongSelf.__delegate?.creditCardFormViewController(strongSelf, didSucceedWithToken: __OmiseToken(token: token))
                }
            case let .fail(err):
                strongSelf.handleError(err)
            }
        })
    }
    
    private func startActivityIndicator() {
        confirmButtonCell?.startActivityIndicator()
        tableView.isUserInteractionEnabled = false
    }
    
    private func stopActivityIndicator() {
        confirmButtonCell?.stopActivityIndicator()
        tableView.isUserInteractionEnabled = true
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 10.0, *) {
            if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    private func updateLabelWidthConstraints() {
        let preferredWidth = formLabels.reduce(CGFloat.leastNormalMagnitude) { (currentPreferredWidth, label)  in
            return max(currentPreferredWidth, label.intrinsicContentSize.width)
        }
        labelWidthConstraints.forEach({ (constraint) in
            constraint.constant = preferredWidth
        })
    }
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
        
        updateLabelWidthConstraints()
    }
}

extension CreditCardFormViewController {
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && handleErrors && hasErrorMessage {
            return max(
                44,
                errorMessageView.systemLayoutSizeFitting(CGSize(width: tableView.bounds.height, height: 0.0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height
                
            )
        } else {
            return 0.0
        }
    }
    
    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && handleErrors && hasErrorMessage {
            return errorMessageView
        } else {
            return nil
        }
    }
    
    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedCell = tableView.cellForRow(at: indexPath), selectedCell == confirmButtonCell {
            return indexPath
        } else {
            return nil
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedCell = tableView.cellForRow(at: indexPath), selectedCell == confirmButtonCell {
            requestToken()
        }
    }
}


// MARK: - Fields Accessory methods
extension CreditCardFormViewController {
    @IBAction func textFieldDidBegin(_ sender: OmiseTextField) {
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
        
        errorMessageView.errorMessageLabel.adjustsFontForContentSizeCategory = true
        confirmButtonCell.confirmPaymentLabel.adjustsFontForContentSizeCategory = true
        formHeaderView.headerLabel.adjustsFontForContentSizeCategory = true
        
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

