import UIKit
import OmiseSDK

class ProductDetailViewController: UIViewController {
    static let segue = "ProductDetailSegue"
    private let publicKey = "pkey_test_4y7dh41kuvvawbhslxw"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product"
    }
    
    // MARK: - Action
    @IBAction func buyNowForModalButtonTapped(sender: AnyObject) {
        let omise = OmiseSDKClient(publicKey: publicKey)
        
        let creditCardView = CreditCardPopoverController(client: omise)
        creditCardView.delegate = self
        creditCardView.autoHandleErrorEnabled = true
        
        let navigationController = UINavigationController(rootViewController: creditCardView)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func buyNowButtonTapped(sender: AnyObject) {
        let omise = OmiseSDKClient(publicKey: publicKey)
        
        let creditCardView = CreditCardPopoverController(client: omise)
        creditCardView.delegate = self
        creditCardView.showCloseButton = false
        
        self.navigationController?.pushViewController(creditCardView, animated: true)
    }
    
    // MARK: Navigation
    func goToCompletePaymentViewController() {
        self.performSegueWithIdentifier(CompletePaymentViewController.segue, sender: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension ProductDetailViewController: CreditCardPopoverDelegate {
    // MARK: CreditCardPopOverViewDelegate
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didSucceededWithToken token: OmiseToken) {
        // Token for create charge
        print("\(token)")
        
        // if charge success
        creditCardPopover.dismiss()
        self.goToCompletePaymentViewController()
        
        // else charge fail
        // func handleChargeError(error)
    }
    
    func creditCardPopover(creditCardPopover: CreditCardPopoverController, didFailWithError error: ErrorType) {
        // Error from SDK
        print(error)
        
        // Dismiss Form if you want
        creditCardPopover.dismiss()
    }
}

