import UIKit

class ProductViewController: UIViewController {
    @IBAction func productDetailButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("ProductDetail", sender: nil)
    }
}
