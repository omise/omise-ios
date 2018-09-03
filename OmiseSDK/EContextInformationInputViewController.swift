import UIKit

class EContextInformationInputViewController: UIViewController, PaymentCreator {
    
    var coordinator: PaymentCreatorTrampoline?
    
    @IBOutlet var fullNameTextField: OmiseTextField!
    @IBOutlet var emailTextField: OmiseTextField!
    @IBOutlet var phoneNumberTextField: OmiseTextField!
    @IBOutlet var submitButton: MainActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitEContextForm(_ sender: UIButton) {
    }
    
}

