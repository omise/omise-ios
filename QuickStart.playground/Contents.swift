/*: omise-ios-quickstart
 
 ![Omise](https://cdn.omise.co/assets/omise.png "Omise")
 
 # iOS SDK QuickStart
 
 To get going quickly, first make sure the SDK can be imported by adding the `import OmiseSDK` to the top of your view controller.
 
 */
import UIKit
import PlaygroundSupport
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
        let button = UIButton(frame: CGRect(x: 10, y: 10,width:  300, height: 44))
        button.addTarget(self, action: #selector(didTapCheckout), for: .touchUpInside)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Checkout", for: .normal)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.backgroundColor = .white
        view.addSubview(button)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkout"
        edgesForExtendedLayout = []
    }
    
    @objc func didTapCheckout() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCloseForm))
        
        let creditCardForm = CreditCardFormController.makeCreditCardForm(withPublicKey: publicKey)
        creditCardForm.delegate = self
        creditCardForm.navigationItem.rightBarButtonItem = closeButton
        
        let navigationController = UINavigationController(rootViewController: creditCardForm)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func didTapCloseForm() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

/*: implement-delegate
 
 The form will automatically tokenizes credit card data for you as the user click on the submit button. To receive the resulting token data, implement the `CreditCardFormDelegate` methods on your view controller.
 
 */
extension CheckoutViewController: CreditCardFormDelegate {
    func creditCardForm(_ controller: CreditCardFormController, didSucceedWithToken token: OmiseToken) {
        didTapCloseForm()
        print("token created: \(token.tokenId ?? "")")
        
        let alert = UIAlertController(title: "Token", message: token.tokenId, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
    
    func creditCardForm(_ controller: CreditCardFormController, didFailWithError error: Error) {
        didTapCloseForm()
        print("error: \(error)")
        
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}

/*: preview
 
 And you are done! Let's add code for trying it out in the playground:
 
 */
let checkoutController = CheckoutViewController()
let navigationController = UINavigationController(rootViewController: checkoutController)

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
window.rootViewController = navigationController
window.makeKeyAndVisible()

PlaygroundPage.current.liveView = window
PlaygroundPage.current.needsIndefiniteExecution = true


