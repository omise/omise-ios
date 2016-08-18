import UIKit

class ConfirmButtonCell: UITableViewCell {
    @IBOutlet weak var confirmPaymentLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isUserInteractionEnabled: Bool {
        get { return super.isUserInteractionEnabled }
        set {
            super.isUserInteractionEnabled = newValue
            confirmPaymentLabel.textColor = newValue ?
                UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0) :
                UIColor.lightGray
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
}
