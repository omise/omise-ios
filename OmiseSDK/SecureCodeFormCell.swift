import UIKit

class SecureCodeFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardCVVTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
}
