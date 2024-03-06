import UIKit

extension UITableViewCell {
    func startAccessoryActivityIndicator() {
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = UIColor.omiseSecondary
        accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        isUserInteractionEnabled = false
    }

    func stopAccessoryActivityIndicator(_ accessoryView: UIView? = nil) {
        self.accessoryView = accessoryView
        isUserInteractionEnabled = false
    }
}
