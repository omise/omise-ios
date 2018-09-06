import UIKit

class EContextInformationInputViewController: UIViewController, PaymentSourceCreator {
    
    var coordinator: PaymentCreatorTrampoline?
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
    
    private var currentEditingTextField: OmiseTextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        requestCreateSource(PaymentInformation.eContext(eContextInformation), completionHandler: { _ in
            self.requestingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.view.tintAdjustmentMode = .automatic
            self.submitButton.isEnabled = true
        })
    }
    
    @IBAction func updateInputAccessoryViewFor(_ sender: OmiseTextField) {
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
    
    @objc @IBAction private func gotoNextField(_ sender: AnyObject) {
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

