import UIKit

class ExpiryDateFormCell: UITableViewCell {
    @IBOutlet weak var textField: CardExpiryDateTextField!
    var month: Int {
        return textField.selectedMonth ?? 0
    }
    
    var year: Int {
        return textField.selectedYear ?? 0
    }
}
