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
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitEContextForm(_ sender: UIButton) {
        guard let fullname = fullNameTextField.text, let email = emailTextField.text,
            let phoneNumber = phoneNumberTextField.text else {
                return
        }
        
        let eContextInformation = PaymentInformation.EContext(name: fullname, email: email, phoneNumber: phoneNumber)
        requestingIndicatorView.startAnimating()
        requestCreateSource(PaymentInformation.eContext(eContextInformation), completionHandler: { _ in
            self.requestingIndicatorView.stopAnimating()
        })
    }
    
}

