import UIKit

public protocol CreditCardPopoverDelegate: class {
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didSucceededWithToken token: OmiseToken)
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didFailWithError error: ErrorType)
}

public class CreditCardPopoverController: UIViewController {
    private let defaultCellHeight: CGFloat = 44.0
    private let formCellsType = [
        FormHeaderCell.self,
        CardNumberFormCell.self,
        NameCardFormCell.self,
        ExpiryDateFormCell.self,
        SecureCodeFormCell.self,
        ErrorMessageCell.self,
        ConfirmButtonCell.self
    ]
    private let cardNumberCellIndex = 0
    private let nameOnCardCellIndex = 1
    private let expiryDateCellIndex = 2
    private let secureCodeCellIndex = 3
  
    private var client: OmiseSDKClient
    private var request: OmiseTokenRequest?
    private var formCells = [UITableViewCell]()
    private var formFields = [OmiseTextField]()
    private var formHeaderCell: FormHeaderCell?
    private var errorMessageCell: ErrorMessageCell?
    private var confirmButtonCell: ConfirmButtonCell?
    private var hasErrorMessage = false
    
    @IBOutlet public weak var formTableView: UITableView!
    
    public weak var delegate: CreditCardPopoverDelegate?
    public var autoHandleErrorEnabled = true
    public var titleColor = UIColor.blackColor()
    public var navigationBarColor = UIColor.whiteColor()
    public var showCloseButton = true
    
    private var cardNumber: String {
        return (formFields[cardNumberCellIndex] as? CardNumberTextField)?.number ?? ""
    }
    
    private var cardName: String {
        return (formFields[nameOnCardCellIndex] as? NameOnCardTextField)?.name ?? ""
    }
    
    private var expirationMonth: Int {
        return (formFields[expiryDateCellIndex] as? CardExpiryDateTextField)?.expirationMonth ?? 0
    }
    
    private var expirationYear: Int {
        return (formFields[expiryDateCellIndex] as? CardExpiryDateTextField)?.expirationYear ?? 0
    }
    
    private var cvv: String {
      return (formFields[secureCodeCellIndex] as? CardCVVTextField)?.cvv ?? ""
    }
    
    public init(client: OmiseSDKClient) {
        self.client = client
        super.init(nibName: "CreditCardPopoverController", bundle: NSBundle(forClass: CreditCardPopoverController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navbar
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
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let visibleCells = formTableView.visibleCells
        for cell in visibleCells {
            for case let field as OmiseTextField in cell.contentView.subviews {
                field.validationDelegate = self
                formFields.append(field)
            }
        }
      
        let accessoryView = OmiseFormAccessoryView()
        accessoryView.attachToTextFields(formFields, inViewController: self)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter().removeObserver(self)
    }
    
    
    public func dismiss() {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func popover(viewController: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            viewController.presentViewController(self, animated: true, completion: nil)
        }
    }
    
    
    @IBAction private func closeButtonTapped(sender: AnyObject) {
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
    
    private func requestToken() {
        view.endEditing(true)
        
        request = OmiseTokenRequest(
            name: cardName,
            number: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            securityCode: cvv
        )
      
        guard let request = request else {
            sdkWarn("OMISE Request is empty.")
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
}

extension CreditCardPopoverController: UITableViewDataSource {
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

extension CreditCardPopoverController: OmiseTextFieldDelegate {
    public func textField(field: OmiseTextField, didChangeValidity isValid: Bool) {
        let valid = formFields.reduce(true) { (valid, field) -> Bool in valid && field.valid }
        confirmButtonCell?.userInteractionEnabled = valid
        
        if let cardField = field as? CardNumberTextField {
            formHeaderCell?.setCardBrand(cardField.cardBrand)
        }
    }
}