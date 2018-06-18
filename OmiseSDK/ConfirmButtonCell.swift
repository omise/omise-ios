import UIKit

class ConfirmButtonCell: UITableViewCell {
    @IBOutlet weak var confirmPaymentLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isUserInteractionEnabled: Bool {
        get { return super.isUserInteractionEnabled }
        set {
            super.isUserInteractionEnabled = newValue
            confirmPaymentLabel.textColor = tintColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        confirmPaymentLabel.textColor = UIColor.lightGray
        isUserInteractionEnabled = false
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
    }
    
    func startActivityIndicator() {
        confirmPaymentLabel.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        confirmPaymentLabel.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        confirmPaymentLabel.textColor = tintColor
    }
}
