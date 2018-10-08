import UIKit
import OmiseSDK



@objc(OMSExampleProductDetailViewController)
class ProductDetailViewController: UIViewController {
    private let publicKey = "<#Omise Public Key#>"
    
    private enum CodePathMode {
        case storyboard
        case code
    }
    
    private var currentCodePathMode = CodePathMode.storyboard
    
    @IBOutlet var heroImageView: ProductHeroImageView!
    @IBOutlet var modeChooser: UISegmentedControl!
    
    var paymentAmount: Int64 = PaymentPreset.thailandPreset.paymentAmount
    var paymentCurrency: Currency = PaymentPreset.thailandPreset.paymentCurrency
    var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.thailandPreset.allowedPaymentMethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptyImage = Tool.imageWith(size: CGSize(width: 1, height: 1), color: .white)?.resizableImage(withCapInsets: .zero)
        navigationController?.navigationBar.setBackgroundImage(
            emptyImage, for: .default
        )
        navigationController?.navigationBar.setBackgroundImage(
            emptyImage, for: .compact
        )
        navigationController?.navigationBar.setBackgroundImage(
            emptyImage, for: .defaultPrompt
        )
        
        navigationController?.navigationBar.shadowImage = emptyImage
        
        let selectedModeBackgroundImage = Tool
            .imageWith(size: CGSize(width: 1, height: 41), actions: { (context) in
                context.setFillColor(UIColor.white.cgColor)
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 40))
                context.setFillColor(view.tintColor.cgColor)
                context.fill(CGRect(x: 0, y: 40, width: 1, height: 1))
            })?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0))
        let backgroundImage = Tool.imageWith(size: CGSize(width: 1, height: 41), color: .white)?.resizableImage(withCapInsets: .zero)
        
        modeChooser.setBackgroundImage(selectedModeBackgroundImage, for: .selected, barMetrics: .default)
        modeChooser.setBackgroundImage(selectedModeBackgroundImage, for: .highlighted, barMetrics: .default)
        modeChooser.setBackgroundImage(backgroundImage, for: [.selected, .highlighted], barMetrics: .default)
        modeChooser.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .highlighted, rightSegmentState: .normal, barMetrics: .default)
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .normal, rightSegmentState: .highlighted, barMetrics: .default)
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .selected, rightSegmentState: .highlighted, barMetrics: .default)
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .highlighted, rightSegmentState: .selected, barMetrics: .default)
        modeChooser.setDividerImage(backgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let highlightedTitleAttributes = [
            NSAttributedString.Key.foregroundColor: view.tintColor!,
            .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout)
        ]
        let normalTitleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.darkText,
            .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout)
        ]
        modeChooser.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        modeChooser.setTitleTextAttributes(normalTitleAttributes, for: .highlighted)
        modeChooser.setTitleTextAttributes(highlightedTitleAttributes, for: .selected)
        modeChooser.setTitleTextAttributes(highlightedTitleAttributes, for: [.selected, .highlighted])
        
        if Locale.current.regionCode == "JP" {
            paymentAmount = PaymentPreset.japanPreset.paymentAmount
            paymentCurrency = PaymentPreset.japanPreset.paymentCurrency
            allowedPaymentMethods = PaymentPreset.japanPreset.allowedPaymentMethods
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "PresentCreditFormWithModal" || identifier == "ShowCreditForm"
            || identifier == "PresentPaymentCreator" {
            return currentCodePathMode == .storyboard
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentCreditFormWithModal",
            let creditCardFormNavigationController = segue.destination as? UINavigationController,
            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormViewController {
            creditCardFormController.publicKey = publicKey
            creditCardFormController.handleErrors = true
            creditCardFormController.delegate = self
        } else if segue.identifier == "ShowCreditForm",
            let creditCardFormController = segue.destination as? CreditCardFormViewController {
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
    
    @IBAction func showModalCreditCardForm(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        let navigationController = UINavigationController(rootViewController: creditCardFormController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showCreditCardForm(_ sender: UIButton) {
        guard currentCodePathMode == .code else {
            return
        }
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        show(creditCardFormController, sender: self)
    }
    
    @IBAction func showModalPaymentCreator(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let paymentCreatorController = PaymentCreatorController.makePaymentCreatorControllerWith(publicKey: publicKey, amount: paymentAmount, currency: paymentCurrency, allowedPaymentMethods: allowedPaymentMethods, paymentDelegate: self)
        present(paymentCreatorController, animated: true, completion: nil)
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
    
    @IBAction func codePathModeChangedHandler(_ sender: UISegmentedControl) {
        let codePathMode: CodePathMode
        
        if sender.selectedSegmentIndex == 1 {
            codePathMode = .code
        } else {
            codePathMode = .storyboard
        }
        
        self.currentCodePathMode = codePathMode
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
        dismissCreditCardForm()
    }
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        paymentCreatorController.present(alertController, animated: true, completion: nil)
    }
    
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController) {
        dismissCreditCardForm()
    }
}


