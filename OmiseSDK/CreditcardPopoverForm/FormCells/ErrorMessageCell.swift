import UIKit

public class ErrorMessageCell: UITableViewCell {    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
        
    func setErrorMessage(message: String) {
        errorMessageLabel.text = message
    }
    
    func removeErrorMesssage() {
        errorMessageLabel.text = ""
    }
}
