import UIKit

public class ConfirmButtonCell: UITableViewCell {
    @IBOutlet weak var confirmPaymentLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public override var userInteractionEnabled: Bool {
        get { return super.userInteractionEnabled }
        set {
            super.userInteractionEnabled = newValue
            confirmPaymentLabel.textColor = newValue ?
                UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0) :
                UIColor.lightGrayColor()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        confirmPaymentLabel.textColor = UIColor.lightGrayColor()
        userInteractionEnabled = false
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
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
