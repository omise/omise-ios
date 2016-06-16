import UIKit

public protocol CreditCardPopoverDelegate: class {
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didSucceededWithToken token: OmiseToken)
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didFailWithError error: ErrorType)
}

public class CreditCardPopoverController: UIViewController {
    public struct CCPOAppearance {
        let defaultTitleColor: UIColor
        let defaultNavigationBarColor: UIColor
        let defaultBackgroundColor: UIColor
        let defaultShadowOpacity: CGFloat
        let defaultButtonDisableBackgroundColor: UIColor
        let defaultButtonBackgroundColor: UIColor
        let defaultButtonTextColor: UIColor
        
        public init(defaultTitleColor: UIColor = UIColor.blackColor(),
                    defaultNavigationBarColor: UIColor = UIColor.whiteColor(),
                    defaultBackgroundColor: UIColor = UIColor(red:239/255, green:239/255, blue:244/255, alpha:1),
                    defaultShadowOpacity: CGFloat = 1.0,
                    defaultButtonDisableBackgroundColor: UIColor = UIColor.lightGrayColor(),
                    defaultButtonBackgroundColor: UIColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0),
                    defaultButtonTextColor: UIColor = UIColor.whiteColor()
                    ) {
            self.defaultTitleColor = defaultTitleColor
            self.defaultNavigationBarColor = defaultNavigationBarColor
            self.defaultBackgroundColor = defaultBackgroundColor
            self.defaultShadowOpacity = defaultShadowOpacity
            self.defaultButtonDisableBackgroundColor = defaultButtonDisableBackgroundColor
            self.defaultButtonBackgroundColor = defaultButtonBackgroundColor
            self.defaultButtonTextColor = defaultButtonTextColor
        }
    }
    
    @IBOutlet weak public var navigationBarView: UIView!
    @IBOutlet weak public var navigationBarTitleLabel: UILabel!
    @IBOutlet weak public var formTableView: UITableView!
    
    public var appearance: CCPOAppearance
    weak public var delegate: CreditCardPopoverDelegate?
    public var autoHandleErrorEnabled: Bool = true
    var client: OmiseSDKClient?
    var request: OmiseTokenRequest?
    private let formButtonTopConstraintSize: CGFloat = 24
    private let formButtonTopConstraintExpandSize: CGFloat = 100    
    private let formCells = [FormHeaderCell.identifier, CardNumberFormCell.identifier, NameCardFormCell.identifier, ExpiryDateFormCell.identifier, SecureCodeFormCell.identifier, ErrorMessageCell.identifier, ConfirmButtonCell.identifier]
    private let defaultCellHeight: CGFloat = 44.0
    private var formFields = [OmiseTextField]()
    private var formHeaderCell: FormHeaderCell?
    private var errorMessageCell: ErrorMessageCell?
    private var confirmButtonCell: ConfirmButtonCell?
    private var hasErrorMessage = false
    private var errorMessageCellHeight = ErrorMessageCell.cellHeight
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController() {
            navigationBarView.removeFromSuperview()
            formTableView.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = formTableView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 64)
            NSLayoutConstraint.activateConstraints([topConstraint])
        }
        
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
        appearance = CCPOAppearance()
        super.init(nibName: "CreditCardPopoverController", bundle: NSBundle(forClass: CreditCardPopoverController.self))
    }
    
    public init(client: OmiseSDKClient, appearance: CCPOAppearance) {
        self.client = client
        self.appearance = appearance
        super.init(nibName: "CreditCardPopoverController", bundle: NSBundle(forClass: CreditCardPopoverController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Setup Appearance
        title = NSLocalizedString("Credit Card Form", tableName: nil, bundle: NSBundle(forClass: CreditCardPopoverController.self), value: "", comment: "")
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        view.backgroundColor = appearance.defaultBackgroundColor
        view.backgroundColor?.colorWithAlphaComponent(appearance.defaultShadowOpacity)

        // Naviagtionbar Title and Navigationbar
        navigationBarTitleLabel.textColor = appearance.defaultTitleColor
        navigationBarView.backgroundColor = appearance.defaultNavigationBarColor
        
        // TableView
        formTableView.delegate = self
        formTableView.dataSource = self
        formTableView.tableFooterView = UIView()
        
        formTableView.registerNib(UINib(nibName: CardNumberFormCell.identifier, bundle: NSBundle(forClass: CardNumberFormCell.self)), forCellReuseIdentifier: CardNumberFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: NameCardFormCell.identifier, bundle: NSBundle(forClass: NameCardFormCell.self)), forCellReuseIdentifier: NameCardFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: ExpiryDateFormCell.identifier, bundle: NSBundle(forClass: ExpiryDateFormCell.self)), forCellReuseIdentifier: ExpiryDateFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: SecureCodeFormCell.identifier, bundle: NSBundle(forClass: SecureCodeFormCell.self)), forCellReuseIdentifier: SecureCodeFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: FormHeaderCell.identifier, bundle: NSBundle(forClass: FormHeaderCell.self)), forCellReuseIdentifier: FormHeaderCell.identifier)
        
        formTableView.registerNib(UINib(nibName: ErrorMessageCell.identifier, bundle: NSBundle(forClass: ErrorMessageCell.self)), forCellReuseIdentifier: ErrorMessageCell.identifier)
        
        formTableView.registerNib(UINib(nibName: ConfirmButtonCell.identifier, bundle: NSBundle(forClass: ConfirmButtonCell.self)), forCellReuseIdentifier: ConfirmButtonCell.identifier)
        
        //Keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
     }
    
    // MARK: Action
    @IBAction func closeButtonTapped(sender: AnyObject) {
        dismiss()
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification){
        if hasErrorMessage {
            errorMessageCellHeight = ErrorMessageCell.cellHeight
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
            setErrorMessageCellHeight(errorString)
            hasErrorMessage = true
            formTableView.beginUpdates()
            formTableView.endUpdates()
        } else {
            delegate?.creditCardPopover(self, didFailWithError: error)
        }
    }
    
    private func setErrorMessageCellHeight(message: String) {
        let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
        label.text = message
        label.sizeToFit()
        errorMessageCellHeight = label.frame.height + defaultCellHeight
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
        
        guard let client = client else {
            OMSFormWarn("OMISE Client is empty.")
            return
        }
        
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
        let identifier = formCells[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if cell.isKindOfClass(FormHeaderCell) {
            if let headerCell = cell as? FormHeaderCell {
                self.formHeaderCell = headerCell
            }
        } else if cell.isKindOfClass(ErrorMessageCell) {
            if let errorMessageCell = cell as? ErrorMessageCell {
                self.errorMessageCell = errorMessageCell
            }
        } else if cell.isKindOfClass(ConfirmButtonCell) {
            if let confirmButtonCell = cell as? ConfirmButtonCell {
                self.confirmButtonCell = confirmButtonCell
            }
        }
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension CreditCardPopoverController: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch formCells[indexPath.row] {
        case FormHeaderCell.identifier:
            return FormHeaderCell.cellHeight
        case ErrorMessageCell.identifier:
            return errorMessageCellHeight
        default:
            return defaultCellHeight
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if ConfirmButtonCell.identifier == formCells[indexPath.row] {
            requestToken()
        }
    }
}
// MARK: - OmiseFormValidatorDelegate
extension CreditCardPopoverController: OmiseFormValidatorDelegate {
    public func textFieldDidValidated(textField: OmiseTextField) {
        if OmiseFormValidator.validateForms(formFields) {
            confirmButtonCell?.setInteractionEnabled(true)
        } else {
            confirmButtonCell?.setInteractionEnabled(false)
        }
        
        if textField.isKindOfClass(CardNumberTextField) {
            let cardField = textField as! CardNumberTextField
            formHeaderCell?.setCardBrand(cardField.cardBrand)
        }
    }
}