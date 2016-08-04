import UIKit

class SecureCodeFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardCVVTextField!
    var value: String {
        return textField.text ?? ""
    }
}
