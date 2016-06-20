import UIKit

public protocol CreditCardPopoverDelegate: class {
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didSucceededWithToken token: OmiseToken)
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didFailWithError error: ErrorType)
}

public class CreditCardPopoverController: UIViewController {
    @IBOutlet weak public var formTableView: UITableView!
    
    var client: OmiseSDKClient
    var request: OmiseTokenRequest?
    weak public var delegate: CreditCardPopoverDelegate?
    public var autoHandleErrorEnabled = true
    public var titleColor = UIColor.blackColor()
    public var navigationBarColor = UIColor.whiteColor()
    public var showCloseButton = true
    
    private var formCells:[UITableViewCell] = []
    
    private let formCellsType = [
        FormHeaderCell.self,
        CardNumberFormCell.self,
        NameCardFormCell.self,
        ExpiryDateFormCell.self,
        SecureCodeFormCell.self,
        ErrorMessageCell.self,
        ConfirmButtonCell.self
    ]

    private let defaultCellHeight: CGFloat = 44.0
    private var formFields = [OmiseTextField]()
    private var formHeaderCell: FormHeaderCell?
    private var errorMessageCell: ErrorMessageCell?
    private var confirmButtonCell: ConfirmButtonCell?
    private var hasErrorMessage = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        NSNotificationCenter().removeObserver(self)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // OMSTextField
        let visibleCells = formTableView.visibleCells
        for cell in visibleCells {
            for case let field as OmiseTextField in cell.contentView.subviews {
                field.omiseValidatorDelegate = self
                formFields.append(field)
            }
        }
        
        // Add input accessory Next/Back/Done
        OmiseTextField.addInputAccessoryForTextFields(self, textFields: formFields, previousNextable: true)
    }
    
    // MARK: Initial
    public init(client: OmiseSDKClient) {
        self.client = client
        super.init(nibName: "CreditCardPopoverController", bundle: NSBundle(forClass: CreditCardPopoverController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Naviagtionbar Title and Navigationbar
        title = NSLocalizedString("Credit Card Form", tableName: nil, bundle: NSBundle(forClass: CreditCardPopoverController.self), value: "", comment: "")
        if showCloseButton {
            let closeBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(dismiss))
            navigationItem.rightBarButtonItem = closeBarButtonItem
        }
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

        // TableView
        let bundle = NSBundle(forClass: CreditCardPopoverController.self)
        formCells = formCellsType.map({ (type) -> UITableViewCell in
            var identifier = String(type)
            if identifier.hasPrefix("OmiseSDK.") {
                let index = identifier.startIndex.advancedBy(9)
                identifier = identifier.substringFromIndex(index)
            }
            
            let cellNib = UINib(nibName: identifier, bundle: bundle)
            formTableView.registerNib(cellNib, forCellReuseIdentifier: identifier)
            return cellNib.instantiateWithOwner(nil, options: nil).first as? UITableViewCell ?? UITableViewCell()
        })
        formTableView.delegate = self
        formTableView.dataSource = self
        formTableView.tableFooterView = UIView()
        formTableView.rowHeight = UITableViewAutomaticDimension
        formTableView.estimatedRowHeight = defaultCellHeight
        
        //Keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
     }
    
    // MARK: Action
    @IBAction func closeButtonTapped(sender: AnyObject) {
        dismiss()
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification){
        if hasErrorMessage {
            errorMessageCell?.removeErrorMesssage()
            hasErrorMessage = false
            formTableView.beginUpdates()
            formTableView.endUpdates()
        }
    }
    
    // MARK: Display & Hide
    public func popover(viewController: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            viewController.presentViewController(self, animated: true, completion: nil)
        }
    }
    
    public func dismiss() {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Error message
    private func handleError(error: ErrorType) {
        if autoHandleErrorEnabled {
            let e = error as! OmiseError
            let errorString = e.nsError.localizedDescription
            errorMessageCell?.setErrorMessage(errorString)
            hasErrorMessage = true
            formTableView.beginUpdates()
            formTableView.endUpdates()
        } else {
            delegate?.creditCardPopover(self, didFailWithError: error)
        }
    }
    
    // MARK: Create token request
    private func requestToken() {
        view.endEditing(true)
        
        request = OmiseTokenRequest(
            name: cardName(),
            number: cardNumber(),
            expirationMonth: expirationMonth(),
            expirationYear: expirationYear(),
            securityCode: cvv()
        )

        guard let request = request else {
            OMSFormWarn("OMISE Request is empty.")
            return
        }
        
        startActivityIndicator()
        client.send(request) { (token, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.stopActivityIndicator()
                if let error = error {
                    self.handleError(error)
                } else if let token = token {
                    self.delegate?.creditCardPopover(self, didSucceededWithToken: token)
                }
            }
        }
    }
    
    private func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.confirmButtonCell?.startActivityIndicator()
            self.formTableView.userInteractionEnabled = false
        }
    }
    
    private func stopActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.confirmButtonCell?.stopActivityIndicator()
            self.formTableView.userInteractionEnabled = true
        }
    }
    
    // MARK: Form Value Getters
    private func cardNumber() -> String {
        for case let cardNumberField as CardNumberTextField in formFields {
            return cardNumberField.number
        }
        return ""
    }
    
    private func cardName() -> String {
        for case let cardNameField as NameOnCardTextField in formFields {
            return cardNameField.name
        }
        return ""
    }
    
    private func expirationMonth() -> Int {
        for case let cardExpiryField as CardExpiryDateTextField in formFields {
            guard let expirationMonth = cardExpiryField.expirationMonth else {
                return 0
            }
            return Int(expirationMonth)
        }
        return 0
    }
    
    private func expirationYear() -> Int {
        for case let cardExpiryField as CardExpiryDateTextField in formFields {
            guard let expirationYear = cardExpiryField.expirationYear else {
                return 0
            }
            return Int(expirationYear)
        }
        return 0
    }
    
    private func cvv() -> String {
        for case let cardCVVField as CardCVVTextField in formFields {
            return cardCVVField.cvv
        }
        return ""
    }
    
    private func OMSFormWarn(message: String) {
        dump("[omise-ios-popup-form] WARN: \(message)")
    }
}

// MARK: - UITableViewDataSource
extension CreditCardPopoverController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formCells.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = formCells[indexPath.row]

        if let headerCell = cell as? FormHeaderCell {
            self.formHeaderCell = headerCell
        } else if let errorMessageCell = cell as? ErrorMessageCell {
            self.errorMessageCell = errorMessageCell
        } else if let confirmButtonCell = cell as? ConfirmButtonCell {
            self.confirmButtonCell = confirmButtonCell
        }
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension CreditCardPopoverController: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return formCells[indexPath.row].systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if formCells[indexPath.row].isKindOfClass(ConfirmButtonCell) {
            requestToken()
        }
    }
}
// MARK: - OmiseFormValidatorDelegate
extension CreditCardPopoverController: OmiseFormValidatorDelegate {
    public func textFieldDidValidated(textField: OmiseTextField) {
        let valid = OmiseFormValidator.validateForms(formFields)
        confirmButtonCell?.setInteractionEnabled(valid)
        
        if let cardField = textField as? CardNumberTextField {
            formHeaderCell?.setCardBrand(cardField.cardBrand)
        }
    }
}