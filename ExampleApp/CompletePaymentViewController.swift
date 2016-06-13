import UIKit

class CompletePaymentViewController: UIViewController {
    static let segue = "CompletePaymentSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func orderDetailButtonTapped(sender: AnyObject) {
        
    }
    
}
