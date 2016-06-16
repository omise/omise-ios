import UIKit

public class ConfirmButtonCell: UITableViewCell {
    public static let identifier = "ConfirmButtonCell"
    
    @IBOutlet weak var confirmPaymentLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        confirmPaymentLabel.textColor = UIColor.lightGrayColor()
        userInteractionEnabled = false
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
    
    func setInteractionEnabled(enabled: Bool) {
        userInteractionEnabled = enabled
        if enabled {
            confirmPaymentLabel.textColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        } else {
            confirmPaymentLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    func startActivityIndicator() {
        confirmPaymentLabel.hidden = true
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        confirmPaymentLabel.hidden = false
        activityIndicator.stopAnimating()
    }
}
