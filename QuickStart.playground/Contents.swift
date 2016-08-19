/*: omise-ios-quickstart
 
 ![Omise](https://cdn.omise.co/assets/omise.png "Omise")
 
 # iOS SDK QuickStart
 
 To get going quickly, first make sure the SDK can be imported by adding the `import OmiseSDK` to the top of your view controller.
 
 */
import UIKit
import XCPlayground
import OmiseSDK

/*: obtain-public-key
 
 To work with the [Omise Token API](https://www.omise.co/tokens-api) from a mobile application, you will need the public key. If you have not done so already, sign up for an account at [https://omise.co](https://omise.co) and visit your [Keys](https://dashboard.omise.co/test/api-keys) page to obtain it.
 
 */
let publicKey = "pkey_test_change_me_to_your_test_key"

/*: credit-card-form
 
 To get going quickly, the SDK provides ready-made credit card form that you can integrate directly into your application's checkout process.
 
 Additionally, to provide consistent experience for the form, we recommend wrapping the form in a `UINavigationController` with a close button.
 
 Let's make a simple view checkout button to try this out:
 
 */
class CheckoutViewController: UIViewController {
    override func loadView() {
        let button = UIButton(frame: CGRectMake(10, 10, 300, 44))
        button.addTarget(self, action: #selector(didTapCheckout), forControlEvents: .TouchUpInside)
        button.backgroundColor = .blueColor()
        button.setTitleColor(.whiteColor(), forState: .Normal)
        button.setTitle("Checkout", forState: .Normal)
        
        let view = UIView(frame: CGRectMake(0, 0, 320, 480))
        view.backgroundColor = .whiteColor()
        view.addSubview(button)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkout"
        edgesForExtendedLayout = .None
    }
    
    func didTapCheckout() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(didTapCloseForm))
        
        let creditCardForm = CreditCardFormController.creditCardFormWithPublicKey(publicKey)
        creditCardForm.delegate = self
        creditCardForm.navigationItem.rightBarButtonItem = closeButton
        
        let navigationController = UINavigationController(rootViewController: creditCardForm)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func didTapCloseForm() {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

/*: implement-delegate
 
 The form will automatically tokenizes credit card data for you as the user click on the submit button. To receive the resulting token data, implement the `CreditCardFormDelegate` methods on your view controller.
 
 */
extension CheckoutViewController: CreditCardFormDelegate {
    func creditCardForm(controller: CreditCardFormController, didSucceedWithToken token: OmiseToken) {
        didTapCloseForm()
        print("token created: \(token.tokenId)")
        
        let alert = UIAlertController(title: "Token", message: token.tokenId, preferredStyle: .Alert)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func creditCardForm(controller: CreditCardFormController, didFailWithError error: ErrorType) {
        didTapCloseForm()
        print("error: \(error)")
        
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
        presentViewController(alert, animated: true, completion: nil)
    }
}

/*: preview
 
 And you are done! Let's add code for trying it out in the playground:
 
 */
let checkoutController = CheckoutViewController()
let navigationController = UINavigationController(rootViewController: checkoutController)

let window = UIWindow(frame: CGRectMake(0, 0, 320, 480))
window.rootViewController = navigationController
window.makeKeyAndVisible()

XCPlaygroundPage.currentPage.liveView = window
