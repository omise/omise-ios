import UIKit

class EContextInformationInputViewController: UIViewController, PaymentSourceCreator {
    
    var coordinator: PaymentCreatorTrampoline?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    @IBOutlet var fullNameTextField: OmiseTextField!
    @IBOutlet var emailTextField: OmiseTextField!
    @IBOutlet var phoneNumberTextField: OmiseTextField!
    @IBOutlet var submitButton: MainActionButton!
    @IBOutlet var requestingIndicatorView: UIActivityIndicatorView!
    
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
}

