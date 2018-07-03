import UIKit

class CardNumberFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardNumberTextField!
    var value: PAN {
        return textField.pan
    }
}
