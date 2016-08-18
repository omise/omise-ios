import UIKit

class CompletePaymentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func orderDetailButtonTapped(_ sender: AnyObject) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}
