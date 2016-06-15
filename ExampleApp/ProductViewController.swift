import UIKit

class ProductViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        // Do any additional setup after loading the view.
    }

    @IBAction func productDetailButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(ProductDetailViewController.segue, sender: nil)
    }
}
