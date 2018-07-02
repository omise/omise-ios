import UIKit

#if CardIO
import OmiseSDK.Private
#endif


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
    fileprivate var hasErrorMessage = false
    
    @IBOutlet var formHeaderView: FormHeaderView!
    @IBOutlet var formFields: [OmiseTextField]! {
        didSet {
            if isViewLoaded, let formFields = formFields {
                accessoryView.attach(to: formFields, in: self)
            }
        }
    }
    
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
    
    @IBOutlet var openCardIOButton: UIButton!
    @IBOutlet var errorMessageView: ErrorMessageView!
    
    let accessoryView = OmiseFormAccessoryView()
    
    /// Omise public key for calling tokenization API.
    @objc public var publicKey: String?
    
    /// Delegate to receive CreditCardFormController result.
    public weak var delegate: CreditCardFormViewControllerDelegate?
    @objc(delegate) public weak var __delegate: OMSCreditCardFormViewControllerDelegate?
    
    /// A boolean flag to enables/disables automatic error handling. Defaults to `true`.
    @objc public var handleErrors = true
    
    /// A boolean flag that enables/disables Card.IO integration.
    @objc public var cardIOEnabled: Bool = true {
        didSet {
            if isViewLoaded && cardIOAvailable && cardIOEnabled {
                cardNumberCell?.textField.rightView = openCardIOButton
                cardNumberCell?.textField.rightViewMode = .always
            } else {
                cardNumberCell?.textField.rightView = nil
                cardNumberCell?.textField.rightViewMode = .never
            }
        }
    }
    
    private var cardIOAvailable: Bool {
        #if CardIO
            return CardIOUtilities.canReadCardWithCamera()
        #else
            return false
        #endif
    }
    
    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    @objc public static func makeCreditCardForm(withPublicKey publicKey: String) -> CreditCardFormViewController {
        let omiseBundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: omiseBundle)
        let creditCardForm = storyboard.instantiateInitialViewController() as! CreditCardFormViewController
        creditCardForm.publicKey = publicKey
        
        return creditCardForm
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        accessoryView.attach(to: formFields, in: self)
        
        if cardIOAvailable && cardIOEnabled {
            cardNumberCell?.textField.rightView = openCardIOButton
            cardNumberCell?.textField.rightViewMode = .always
        }
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        let preferredWidth = formLabels.reduce(CGFloat.leastNormalMagnitude) { (currentPreferredWidth, label)  in
            return max(currentPreferredWidth, label.intrinsicContentSize.width)
        }
        
        labelWidthConstraints.forEach { (constraint) in
            constraint.constant = preferredWidth
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        formFields.forEach({ (field) in
            field.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
        })
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        formFields.forEach({ (field) in
            field.removeTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
        })
        NotificationCenter().removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc private func fieldDidChange(_ sender: AnyObject) {
        updateSupplementaryUI()
    }
    
    @objc private func keyboardWillAppear(_ notification: Notification){
        if hasErrorMessage {
            errorMessageView?.removeErrorMesssage()
            hasErrorMessage = false
            tableView.beginUpdates()
            tableView.endUpdates()
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
    
    fileprivate func updateSupplementaryUI() {
        let valid = formFields.reduce(into: true, { (valid, field) in
            valid = valid && field.isValid
        })
        confirmButtonCell?.isUserInteractionEnabled = valid
        
        formHeaderView?.setCardBrand(cardNumberTextField.cardBrand)
    }
    
    fileprivate func requestToken() {
        view.endEditing(true)
        guard let publicKey = publicKey else {
            assertionFailure("Missing public key information. Please setting the public key before request token.")
            return
        }
        
        startActivityIndicator()
        let request = Request<Token>(
            name: cardNameCell?.value ?? "",
            number: cardNumberCell?.value ?? "",
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
    
    @IBAction func presentCardIOViewController() {
        #if CardIO
            guard let cardIOController = CardIOPaymentViewController(paymentDelegate: self) else {
                return
            }
            cardIOController.hideCardIOLogo = true
            cardIOController.disableManualEntryButtons = true
            cardIOController.collectCVV = false
            cardIOController.collectExpiry = true
            cardIOController.scanExpiry = true
            cardIOController.suppressScanConfirmation = true
            present(cardIOController, animated: true, completion: nil)
        #endif
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

#if CardIO
extension CreditCardFormViewController: CardIOPaymentViewControllerDelegate {
    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    public func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let cardNumber = cardInfo.cardNumber {
            cardNumberTextField.text = cardNumber
        }
        
        if 1...12 ~= cardInfo.expiryMonth && cardInfo.expiryYear > 0 {
            expiryDateTextField.text = String(format: "%02d/%d", cardInfo.expiryMonth, cardInfo.expiryYear - 2000)
        }
        
        updateSupplementaryUI()
        
        dismiss(animated: true, completion: {
            if self.cardNameTextField.text?.isEmpty ?? true {
                self.cardNameTextField.becomeFirstResponder()
            } else if self.secureCodeTextField.text?.isEmpty ?? true {
                self.secureCodeTextField.becomeFirstResponder()
            }
        })
    }
}
#endif

