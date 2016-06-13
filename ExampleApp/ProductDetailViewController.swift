import UIKit
import OmiseSDK

class ProductDetailViewController: UIViewController, CreditCardPopOverViewDelegate {
    static let segue = "ProductDetailSegue"
    private let publicKey = "pkey_test_4y7dh41kuvvawbhslxw"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showButtonTapped(sender: AnyObject) {
        let omise = OmiseSDKClient(publicKey: publicKey)
        
        let creditCardView = CreditCardPopOverView(client: omise)
        creditCardView.delegate = self
        creditCardView.autoHandleErrorEnabled = true
        creditCardView.popOver(self)
    }
    
    // MARK: CreditCardPopOverViewDelegate
    func creditCardPopOver(creditCardPopOver: CreditCardPopOverView, didSucceededWithToken token: OmiseToken) {
        // Token for create charge
        print("\(token)")
        
        // if charge success
        creditCardPopOver.dismiss()
        self.goToCompletePaymentViewController()
        
        // else charge fail
        // func handleChargeError(error)
    }
    
    func creditCardPopOver(creditCardPopOver: CreditCardPopOverView, didFailWithError error: ErrorType) {
        // Error from SDK
        print(error)
        
        // Dismiss Form if you want
        creditCardPopOver.dismiss()
    }
    
    // MARK: Navigation
    func goToCompletePaymentViewController() {
        self.performSegueWithIdentifier(CompletePaymentViewController.segue, sender: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

