import UIKit

public class SecureCodeFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardCVVTextField!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
}
