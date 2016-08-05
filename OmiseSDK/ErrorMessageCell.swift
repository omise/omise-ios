import UIKit

class ErrorMessageView: UIView {
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    func setErrorMessage(message: String) {
        errorMessageLabel.text = message
    }
    
    func removeErrorMesssage() {
        errorMessageLabel.text = ""
    }
}

