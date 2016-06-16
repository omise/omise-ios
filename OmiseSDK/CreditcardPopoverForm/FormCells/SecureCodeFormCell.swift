import UIKit

public class SecureCodeFormCell: UITableViewCell {
    public static let identifier = "SecureCodeFormCell"

    @IBOutlet weak var textField: CardCVVTextField!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
}
