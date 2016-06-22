import UIKit

public protocol CreditCardFormDelegate: class {
    func creditCardForm(controller: CreditCardFormController, didSucceedWithToken token: OmiseToken)
    func creditCardForm(controller: CreditCardFormController, didFailWithError error: ErrorType)
}

public class CreditCardFormController: UIViewController {
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
    
    private let publicKey: String
    
    public weak var delegate: CreditCardFormDelegate?
    public var handleErrors = true
    
    private var hasErrorMessage = false
    @IBOutlet private weak var formTableView: UITableView!
    private var formCells = [UITableViewCell]()
    private var formFields = [OmiseTextField]()
    
    private var formHeaderCell: FormHeaderCell? {
        return formCells[0] as? FormHeaderCell
    }
    
    private var cardNumberCell: CardNumberFormCell? {
        return formCells[1] as? CardNumberFormCell
    }
    
    private var cardNameCell: NameCardFormCell? {
        return formCells[2] as? NameCardFormCell
    }
    
    private var expiryDateCell: ExpiryDateFormCell? {
        return formCells[3] as? ExpiryDateFormCell
    }
    
    private var secureCodeCell: SecureCodeFormCell? {
        return formCells[4] as? SecureCodeFormCell
    }
    
    private var errorMessageCell: ErrorMessageCell? {
        return formCells[5] as? ErrorMessageCell
    }
    
    private var confirmButtonCell: ConfirmButtonCell? {
        return formCells[6] as? ConfirmButtonCell
    }
    
    public init(publicKey: String) {
        self.publicKey = publicKey
        super.init(nibName: "CreditCardFormController", bundle: NSBundle(forClass: CreditCardFormController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Credit Card Form", tableName: nil, bundle: NSBundle(forClass: CreditCardFormController.self), value: "", comment: "")
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

        let bundle = NSBundle(forClass: CreditCardFormController.self)
        formCells = formCellsType.map({ (type) -> UITableViewCell in
            var identifier = String(type)
            if identifier.hasPrefix("OmiseSDK.") {
                let index = identifier.startIndex.advancedBy(9)
                identifier = identifier.substringFromIndex(index)
            }
            
            let cellNib = UINib(nibName: identifier, bundle: bundle)
            return cellNib.instantiateWithOwner(nil, options: nil).first as? UITableViewCell ?? UITableViewCell()
        })
        
        formTableView.delegate = self
        formTableView.dataSource = self
        formTableView.tableFooterView = UIView()
        formTableView.rowHeight = UITableViewAutomaticDimension
        formTableView.estimatedRowHeight = defaultCellHeight
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let visibleCells = formTableView.visibleCells
        for cell in visibleCells {
            for case let field as OmiseTextField in cell.contentView.subviews {
                field.addTarget(self, action: #selector(fieldDidChange), forControlEvents: .EditingChanged)
                formFields.append(field)
            }
        }
      
        let accessoryView = OmiseFormAccessoryView()
        accessoryView.attachToTextFields(formFields, inViewController: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter().removeObserver(self)
    }
    
    
    @objc private func fieldDidChange(sender: AnyObject) {
        validateForm()
        
        if let cardNumberField = sender as? CardNumberTextField {
            formHeaderCell?.setCardBrand(cardNumberField.cardBrand)
        }
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
        guard handleErrors else {
            delegate?.creditCardForm(self, didFailWithError: error)
            return
        }
        
        let e = error as! OmiseError
        let errorString = e.nsError.localizedDescription
        errorMessageCell?.setErrorMessage(errorString)
        hasErrorMessage = true
        formTableView.beginUpdates()
        formTableView.endUpdates()
    }
    
    private func validateForm() {
        let valid = formFields.reduce(true) { (valid, field) -> Bool in valid && field.isValid }
        confirmButtonCell?.userInteractionEnabled = valid
    }
    
    private func requestToken() {
        view.endEditing(true)
        startActivityIndicator()
        
        let request = OmiseTokenRequest(
            name: cardNameCell?.value ?? "",
            number: cardNumberCell?.value ?? "",
            expirationMonth: expiryDateCell?.month ?? 0,
            expirationYear: expiryDateCell?.year ?? 0,
            securityCode: secureCodeCell?.value ?? ""
        )
        
        let client = OmiseSDKClient(publicKey: publicKey)
        client.send(request) { [weak self] (token, error) in
            dispatch_async(dispatch_get_main_queue()) {
                guard let s = self else { return }
                
                s.stopActivityIndicator()
                if let error = error {
                    s.handleError(error)
                } else if let token = token {
                    s.delegate?.creditCardForm(s, didSucceedWithToken: token)
                }
            }
        }
    }
    
    private func startActivityIndicator() {
        confirmButtonCell?.startActivityIndicator()
        formTableView.userInteractionEnabled = false
    }
    
    private func stopActivityIndicator() {
        confirmButtonCell?.stopActivityIndicator()
        formTableView.userInteractionEnabled = true
    }
}

extension CreditCardFormController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formCells.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = formCells[indexPath.row]
        return cell
    }
}

extension CreditCardFormController: UITableViewDelegate {
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