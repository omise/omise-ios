import UIKit

class EContextInformationInputViewController: UIViewController, PaymentSourceChooser, PaymentChooserUI, PaymentFormUIController {
    var flowSession: PaymentSourceCreatorFlowSession?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet var fullNameTextField: OmiseTextField!
    @IBOutlet var emailTextField: OmiseTextField!
    @IBOutlet var phoneNumberTextField: OmiseTextField!
    @IBOutlet var submitButton: MainActionButton!
    @IBOutlet var requestingIndicatorView: UIActivityIndicatorView!
    
    
    @IBOutlet var formLabels: [UILabel]!
    @IBOutlet var formFields: [OmiseTextField]!
    @IBOutlet var formFieldsAccessoryView: UIToolbar!
    @IBOutlet var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var gotoNextFieldBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneEditingBarButtonItem: UIBarButtonItem!
    
    var currentEditingTextField: OmiseTextField?

    @IBInspectable @objc public var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    @IBInspectable @objc public var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyPrimaryColor()
        applySecondaryColor()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        formFields.forEach({
            $0.inputAccessoryView = formFieldsAccessoryView
        })
        
        if #available(iOS 10.0, *) {
            formFields.forEach({
                $0.adjustsFontForContentSizeCategory = true
            })
            formLabels.forEach({
                $0.adjustsFontForContentSizeCategory = true
            })
            submitButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
        
        NotificationCenter.default.addObserver(
            self, selector:#selector(keyboardWillChangeFrame(_:)),
            name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector:#selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide, object: nil
        )
    }
    
    @IBAction func submitEContextForm(_ sender: AnyObject) {
        guard let fullname = fullNameTextField.text, let email = emailTextField.text,
            let phoneNumber = phoneNumberTextField.text else {
                return
        }
        
        let eContextInformation = PaymentInformation.EContext(name: fullname, email: email, phoneNumber: phoneNumber)
        requestingIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        view.tintAdjustmentMode = .dimmed
        submitButton.isEnabled = false
        flowSession?.requestCreateSource(PaymentInformation.eContext(eContextInformation), completionHandler: { _ in
            self.requestingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.view.tintAdjustmentMode = .automatic
            self.submitButton.isEnabled = true
        })
    }
    
    @IBAction func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
        updateInputAccessoryViewWithFirstResponder(sender)
    }
    
    @objc @IBAction private func gotoPreviousField(_ button: UIBarButtonItem) {
        gotoPreviousField()
    }
    
    @objc @IBAction private func gotoNextField(_ sender: AnyObject) {
        gotoNextField()
    }
    
    @objc @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }

    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let frameEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let frameStart = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
            frameEnd != frameStart else {
                return
        }
        
        let intersectedFrame = contentView.convert(frameEnd, from: nil)
        
        contentView.contentInset.bottom = intersectedFrame.height
        let bottomScrollIndicatorInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomScrollIndicatorInset = intersectedFrame.height - contentView.safeAreaInsets.bottom
        } else {
            bottomScrollIndicatorInset = intersectedFrame.height
        }
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        contentView.contentInset.bottom = 0.0
        contentView.scrollIndicatorInsets.bottom = 0.0
    }
    
   
}

