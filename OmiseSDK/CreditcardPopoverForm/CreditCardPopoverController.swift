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
    @IBOutlet weak public var formButton: UIButton!
    @IBOutlet weak var formButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var bottomLineHeight: NSLayoutConstraint!
    @IBOutlet weak var errorTextView: UITextView!
    
    
    public var appearance: CCPOAppearance
    weak public var delegate: CreditCardPopoverDelegate?
    public var autoHandleErrorEnabled: Bool = true
    var client: OmiseSDKClient?
    var request: OmiseTokenRequest?
    private let formButtonTopConstraintSize: CGFloat = 24
    private let formButtonTopConstraintExpandSize: CGFloat = 100    
    private let formCells = [CardNumberFormCell.identifier, NameCardFormCell.identifier, ExpiryDateFormCell.identifier, SecureCodeFormCell.identifier]
    private var formFields = [OmiseTextField]()
    private var formHeaderCell: FormHeaderCell?
    
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
            let heightConstraint = formTableView.heightAnchor.constraintEqualToAnchor(nil, constant: 240)
            NSLayoutConstraint.activateConstraints([topConstraint, heightConstraint])
        }
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
        
        // Form Button
        formButton.setTitleColor(appearance.defaultButtonTextColor, forState: .Normal)
        formButton.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        formButton.backgroundColor = appearance.defaultButtonDisableBackgroundColor
        formButton.enabled = false
        
        // TableView
        formTableView.delegate = self
        formTableView.dataSource = self
        formTableView.tableFooterView = UIView()
        bottomLineHeight.constant = 0.5
        
        formTableView.registerNib(UINib(nibName: CardNumberFormCell.identifier, bundle: NSBundle(forClass: CardNumberFormCell.self)), forCellReuseIdentifier: CardNumberFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: NameCardFormCell.identifier, bundle: NSBundle(forClass: NameCardFormCell.self)), forCellReuseIdentifier: NameCardFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: ExpiryDateFormCell.identifier, bundle: NSBundle(forClass: ExpiryDateFormCell.self)), forCellReuseIdentifier: ExpiryDateFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: SecureCodeFormCell.identifier, bundle: NSBundle(forClass: SecureCodeFormCell.self)), forCellReuseIdentifier: SecureCodeFormCell.identifier)
        
        formTableView.registerNib(UINib(nibName: FormHeaderCell.identifier, bundle: NSBundle(forClass: FormHeaderCell.self)), forCellReuseIdentifier: FormHeaderCell.identifier)
        formButton.layer.cornerRadius = 4
        
        // Gesture Recognizer for tapping to hide
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnBaseView(_:)))
        view.addGestureRecognizer(tapGesture)
        
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
    
    // MARK: Action
    @IBAction func formButtonTapped(sender: AnyObject) {
        view.endEditing(true)
        
        request = OmiseTokenRequest(
            name: cardName(),
            number: cardNumber(),
            expirationMonth: expirationMonth(),
            expirationYear: expirationYear(),
            securityCode: cvv()
        )
        
        requestToken()
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        dismiss()
    }
    
    func tappedOnBaseView(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
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
            errorTextView.text = errorString
            errorTextView.textColor = UIColor.redColor()
            formButtonTopConstraint.constant = formButtonTopConstraintExpandSize
            UIView.animateWithDuration(1) {
                self.view.layoutIfNeeded()
            }
        } else {
            delegate?.creditCardPopover(self, didFailWithError: error)
        }
    }
    
    private func clearErrorMessage() {
        errorTextView.text = ""
        formButtonTopConstraint.constant = formButtonTopConstraintSize
        UIView.animateWithDuration(1) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Create token request
    private func requestToken() {
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
            self.formTableView.userInteractionEnabled = false
            self.formButton.enabled = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    private func stopActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.formTableView.userInteractionEnabled = true
            self.formButton.enabled = true
            self.activityIndicatorView.stopAnimating()
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
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension CreditCardPopoverController: UITableViewDelegate {
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier(FormHeaderCell.identifier) as! FormHeaderCell
        formHeaderCell = headerCell
        return headerCell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FormHeaderCell.cellHeight
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
// MARK: - OmiseFormValidatorDelegate
extension CreditCardPopoverController: OmiseFormValidatorDelegate {
    public func textFieldDidValidated(textField: OmiseTextField) {
        if OmiseFormValidator.validateForms(formFields) {
            formButton.backgroundColor = appearance.defaultButtonBackgroundColor
            formButton.enabled = true
        } else {
            formButton.backgroundColor = UIColor.lightGrayColor()
            formButton.enabled = false
        }
        
        if textField.isKindOfClass(CardNumberTextField) {
            let cardField = textField as! CardNumberTextField
            formHeaderCell?.setCardBrand(cardField.cardBrand)
        }
        
        if autoHandleErrorEnabled {
            clearErrorMessage()
        }
    }
}