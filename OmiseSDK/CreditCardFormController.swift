import UIKit

#if CardIO
import OmiseSDK.Private
#endif


public protocol CreditCardFormDelegate: class {
    func creditCardForm(controller: CreditCardFormController, didSucceedWithToken token: OmiseToken)
    func creditCardForm(controller: CreditCardFormController, didFailWithError error: ErrorType)
}


public class CreditCardFormController: UITableViewController {
    public var publicKey: String?
    
    public weak var delegate: CreditCardFormDelegate?
    public var handleErrors = true
    
    private var hasErrorMessage = false
    
    @IBOutlet var formHeaderView: FormHeaderView!
    @IBOutlet var formFields: [OmiseTextField]! {
      didSet {
        if isViewLoaded(), let formFields = formFields {
          
          accessoryView.attachToTextFields(formFields, inViewController: self)
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
    
    
    /// A boolean indicates that CreditCardForm should displays capture card information via card.io button.
    public var cardIOEnabled: Bool = true {
        didSet {
            if isViewLoaded() && cardIOAvailable && cardIOEnabled {
                cardNumberCell?.textField.rightView = openCardIOButton
                cardNumberCell?.textField.rightViewMode = .Always
            } else {
                cardNumberCell?.textField.rightView = nil
                cardNumberCell?.textField.rightViewMode = .Never
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
    
    @objc public static func creditCardFormWithPublicKey(publicKey: String) -> CreditCardFormController {
        let omiseBundle = NSBundle(forClass: self)
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: omiseBundle)
        let creditCardForm = storyboard.instantiateInitialViewController() as! CreditCardFormController
        creditCardForm.publicKey = publicKey
        
        return creditCardForm
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        accessoryView.attachToTextFields(formFields, inViewController: self)
        
        if cardIOAvailable && cardIOEnabled {
            cardNumberCell?.textField.rightView = openCardIOButton
            cardNumberCell?.textField.rightViewMode = .Always
        }
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        let preferredWidth = formLabels.reduce(CGFloat.min) { (currentPreferredWidth, label)  in
            return max(currentPreferredWidth, label.intrinsicContentSize().width)
        }
        
        labelWidthConstraints.forEach { (constraint) in
            constraint.constant = preferredWidth
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        formFields.forEach({ (field) in
            field.addTarget(self, action: #selector(fieldDidChange), forControlEvents: .EditingChanged)
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        formFields.forEach({ (field) in
            field.removeTarget(self, action: #selector(fieldDidChange), forControlEvents: .EditingChanged)
        })
        NSNotificationCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    @objc private func fieldDidChange(sender: AnyObject) {
        validateForm()
        
        if let cardNumberField = sender as? CardNumberTextField {
            formHeaderView?.setCardBrand(cardNumberField.cardBrand)
        }
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification){
        if hasErrorMessage {
            errorMessageView?.removeErrorMesssage()
            hasErrorMessage = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    private func handleError(error: ErrorType) {
        guard handleErrors else {
            delegate?.creditCardForm(self, didFailWithError: error)
            return
        }
        
        let errorString: String
        switch error {
        case let error as OmiseError:
            errorString = error.nsError.localizedDescription
        default:
            errorString = (error as NSError).localizedDescription
        }
        
        errorMessageView?.setErrorMessage(errorString)
        hasErrorMessage = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func validateForm() {
        let valid = formFields.reduce(true) { (valid, field) -> Bool in valid && field.isValid }
        confirmButtonCell?.userInteractionEnabled = valid
    }
    
    private func requestToken() {
        view.endEditing(true)
        guard let publicKey = publicKey else {
            assertionFailure("Missing public key information. Please setting the public key before request token.")
            return
        }
        
        startActivityIndicator()
        let request = OmiseTokenRequest(
            name: cardNameCell?.value ?? "",
            number: cardNumberCell?.value ?? "",
            expirationMonth: expiryDateCell?.month ?? 0,
            expirationYear: expiryDateCell?.year ?? 0,
            securityCode: secureCodeCell?.value ?? ""
        )
        
        let client = OmiseSDKClient(publicKey: publicKey)
        client.send(request) { [weak self] (result) in
            guard let s = self else { return }
            
            s.stopActivityIndicator()
            switch result {
            case let .Succeed(token):
                s.delegate?.creditCardForm(s, didSucceedWithToken: token)
            case let .Fail(err):
                s.handleError(err)
            }
        }
    }
    
    private func startActivityIndicator() {
        confirmButtonCell?.startActivityIndicator()
        tableView.userInteractionEnabled = false
    }
    
    private func stopActivityIndicator() {
        confirmButtonCell?.stopActivityIndicator()
        tableView.userInteractionEnabled = true
    }
    
    @IBAction func presentCardIOViewController() {
        #if CardIO
        let cardIOController = CardIOPaymentViewController(paymentDelegate: self)
        cardIOController.hideCardIOLogo = true
        cardIOController.disableManualEntryButtons = true
        cardIOController.collectCVV = false
        cardIOController.collectExpiry = true
        cardIOController.scanExpiry = true
        cardIOController.suppressScanConfirmation = true
        presentViewController(cardIOController, animated: true, completion: nil)
        #endif
    }

}

extension CreditCardFormController {
    public override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && handleErrors && hasErrorMessage {
            return max(
                44,
                errorMessageView.systemLayoutSizeFittingSize(CGSize(width: tableView.bounds.height, height: 0.0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel).height
            
            )
        } else {
            return 0.0
        }
    }
    
    public override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && handleErrors && hasErrorMessage {
            return errorMessageView
        } else {
            return nil
        }
    }
    
    public override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) where selectedCell == confirmButtonCell {
            return indexPath
        } else {
            return nil
        }
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) where selectedCell == confirmButtonCell {
            requestToken()
        }
    }
}

#if CardIO
extension CreditCardFormController: CardIOPaymentViewControllerDelegate {
    public func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let cardNumber = cardInfo.cardNumber {
            cardNumberTextField.text = cardNumber
        }
        
        if 1...12 ~= cardInfo.expiryMonth && cardInfo.expiryYear > 0 {
            expiryDateTextField.text = String(format: "%02d/%d", cardInfo.expiryMonth, cardInfo.expiryYear - 2000)
        }
        
        dismissViewControllerAnimated(true, completion: { _ in
            if self.cardNameTextField.text?.isEmpty ?? true {
               self.cardNameTextField.becomeFirstResponder()
            } else if self.secureCodeTextField.text?.isEmpty ?? true {
                self.secureCodeTextField.becomeFirstResponder()
            }
        })
    }
}
#endif

