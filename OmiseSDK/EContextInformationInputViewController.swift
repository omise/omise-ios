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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func submitEContextForm(_ sender: UIButton) {
        guard let fullname = fullNameTextField.text, let email = emailTextField.text,
            let phoneNumber = phoneNumberTextField.text else {
                return
        }
        
        let eContextInformation = PaymentInformation.EContext(name: fullname, email: email, phoneNumber: phoneNumber)
        requestingIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        view.tintAdjustmentMode = .dimmed
        sender.isEnabled = false
        requestCreateSource(PaymentInformation.eContext(eContextInformation), completionHandler: { _ in
            self.requestingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.view.tintAdjustmentMode = .automatic
            sender.isEnabled = true
        })
    }
    
}

