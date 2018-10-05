import UIKit
import OmiseSDK


struct PaymentPreset {
    var paymentAmount: Int64
    var paymentCurrency: Currency
    var allowedPaymentMethods: [OMSSourceTypeValue]
    
    static let thailandPreset = PaymentPreset(
        paymentAmount: 5_00_00, paymentCurrency: .thb,
        allowedPaymentMethods: PaymentCreatorController.thailandDefaultAvailableSourceMethods
    )
    
    static let japanPreset = PaymentPreset(
        paymentAmount: 5_000, paymentCurrency: .jpy,
        allowedPaymentMethods: PaymentCreatorController.japanDefaultAvailableSourceMethods
    )
}


@objc(OMSExampleProductDetailViewController)
class ProductDetailViewController: UIViewController {
    private let publicKey = "<#Omise Public Key#>"

    var paymentAmount: Int64 = PaymentPreset.thailandPreset.paymentAmount
    var paymentCurrency: Currency = PaymentPreset.thailandPreset.paymentCurrency
    var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.thailandPreset.allowedPaymentMethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Locale.current.regionCode == "JP" {
            paymentAmount = PaymentPreset.japanPreset.paymentAmount
            paymentCurrency = PaymentPreset.japanPreset.paymentCurrency
            allowedPaymentMethods = PaymentPreset.japanPreset.allowedPaymentMethods
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentCreditFormWithModal",
            let creditCardFormNavigationController = segue.destination as? UINavigationController,
            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormViewController {
            creditCardFormController.publicKey = publicKey
            creditCardFormController.handleErrors = true
            creditCardFormController.delegate = self
        } else if segue.identifier == "PresentPaymentCreator",
            let paymentCreatorController = segue.destination as? PaymentCreatorController {
            paymentCreatorController.publicKey = self.publicKey
            paymentCreatorController.paymentAmount = paymentAmount
            paymentCreatorController.paymentCurrency = paymentCurrency
            paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
            paymentCreatorController.paymentDelegate = self
        } else if segue.identifier == "PresentPaymentSettingScene",
            let settingNavigationController = segue.destination as? UINavigationController,
            let settingViewController = settingNavigationController.topViewController as? PaymentSettingTableViewController {
            settingViewController.currentAmount = paymentAmount
            settingViewController.currentCurrency = paymentCurrency
            settingViewController.allowedPaymentMethods = Set(allowedPaymentMethods)
        }
    }
    
    @IBAction func showCreditCardForm(_ sender: UIButton) {
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        show(creditCardFormController, sender: self)
    }
    
    @objc private func dismissCreditCardForm() {
        dismissCreditCardFormWithCompletion(nil)
    }
    
    @objc private func dismissCreditCardFormWithCompletion(_ completion: (() -> Void)?) {
        if presentedViewController != nil {
            dismiss(animated: true, completion: completion)
        } else {
            _ = navigationController?.popToViewController(self, animated: true)
            completion?()
        }
    }
    
    @objc(updatePaymentInformationFromSetting:)
    @IBAction private func updatePaymentInformation(fromSetting sender: UIStoryboardSegue) {
        guard let settingViewController = sender.source as? PaymentSettingTableViewController else {
            return
        }
        
        paymentAmount = settingViewController.currentAmount
        paymentCurrency = settingViewController.currentCurrency
        allowedPaymentMethods = Array(settingViewController.allowedPaymentMethods)
    }
    
    @IBAction func handlingAuthorizingPayment(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Authorizing Payment", message: "Please input your given authorized URL", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: AlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: AlertActionStyle.default, handler: { (_) in
            guard let textField = alertController.textFields?.first, let text = textField.text,
                let url = URL(string: text) else { return }
            
            let expectedReturnURL = URLComponents(string: "http://www.example.com/orders")!
            let handlerController =
                AuthorizingPaymentViewController
                    .makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(
                        url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
            self.present(handlerController, animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}

extension ProductDetailViewController: CreditCardFormViewControllerDelegate {
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
        dismissCreditCardForm()
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        dismissCreditCardFormWithCompletion({
            self.performSegue(withIdentifier: "CompletePayment", sender: self)
        })
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        dismissCreditCardForm()
    }
}

extension ProductDetailViewController: AuthorizingPaymentViewControllerDelegate {
    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
        print(redirectedURL)
        dismiss(animated: true, completion: nil)
    }
    
    func authorizingPaymentViewControllerDidCancel(_ viewController: AuthorizingPaymentViewController) {
        dismiss(animated: true, completion: nil)
    }
}


extension ProductDetailViewController: PaymentCreatorControllerDelegate {
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        paymentCreatorController.present(alertController, animated: true, completion: nil)
    }
    
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController) {
        dismiss(animated: true, completion: nil)
    }
    
}


