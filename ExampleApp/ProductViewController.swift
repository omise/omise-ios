import UIKit

class ProductViewController: UIViewController {
    @IBAction func productDetailButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ProductDetail", sender: nil)
    }
}
