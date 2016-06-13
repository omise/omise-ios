import UIKit

class ProductViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func productDetailButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(ProductDetailViewController.segue, sender: nil)
    }
}
