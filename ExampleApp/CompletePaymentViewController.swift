import UIKit

class CompletePaymentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func orderDetailButtonTapped(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
