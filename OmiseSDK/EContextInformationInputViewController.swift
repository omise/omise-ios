import UIKit

class EContextInformationInputViewController: UIViewController {
    
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

