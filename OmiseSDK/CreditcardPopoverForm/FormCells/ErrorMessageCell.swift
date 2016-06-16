import UIKit

public class ErrorMessageCell: UITableViewCell {
    public static let identifier = "ErrorMessageCell"
    public static let cellHeight:CGFloat = 28
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    public override func awakeFromNib() {
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsetsZero
    }
        
    func setErrorMessage(message: String) {
        errorMessageLabel.text = message
    }
    
    func removeErrorMesssage() {
        errorMessageLabel.text = ""
    }
}
