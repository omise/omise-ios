import UIKit

class CardNumberFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardNumberTextField!
    var value: String {
        return textField.text ?? ""
    }
}
