import UIKit

class NameCardFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardNameTextField!
    var value: String {
        return textField.text ?? ""
    }
}
