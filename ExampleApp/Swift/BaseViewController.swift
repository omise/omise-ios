import UIKit
import OmiseSDK

class BaseViewController: UIViewController {
    enum CodePathMode {
        case storyboard
        case code
    }
    
    var currentCodePathMode: CodePathMode = .storyboard
    var paymentAmount: Int64!
    var paymentCurrencyCode: String!
    var usesCapabilityDataForPaymentMethods: Bool = true
    var allowedPaymentMethods: [SourceType]!
    
    @IBOutlet var modeChooser: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usesCapabilityDataForPaymentMethods = true
        
        // Workaround of iOS 12 bug on the tint color
        self.view.tintColor = nil
        self.navigationController?.navigationBar.tintColor = nil
        
        switch Locale.current.regionCode {
        case "JP":
            self.paymentAmount = Tool.japanPaymentAmount
            self.paymentCurrencyCode = Tool.japanPaymentCurrency
            self.allowedPaymentMethods = Tool.japanAllowedPaymentMethods
        case "SG":
            self.paymentAmount = Tool.singaporePaymentAmount
            self.paymentCurrencyCode = Tool.singaporePaymentCurrency
            self.allowedPaymentMethods = Tool.singaporeAllowedPaymentMethods
        default:
            self.paymentAmount = Tool.thailandPaymentAmount
            self.paymentCurrencyCode = Tool.thailandPaymentCurrency
            self.allowedPaymentMethods = Tool.thailandAllowedPaymentMethods
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentPaymentSettingScene" {
            let settingNavigationController = segue.destination as! UINavigationController
            let settingViewController = settingNavigationController.topViewController as! PaymentSettingTableViewController
            
            settingViewController.currentAmount = paymentAmount
            settingViewController.currentCurrencyCode = paymentCurrencyCode
            settingViewController.usesCapabilityDataForPaymentMethods = usesCapabilityDataForPaymentMethods
            settingViewController.allowedPaymentMethods = allowedPaymentMethods.reduce(into: Set<SourceType>(), { (sourceTypes, object) in
                sourceTypes.insert(object)
            })
        }
    }
    
    func dismissForm() {
        dismissForm(completion: nil)
    }
    
    func dismissForm(completion: (() -> Void)?) {
        if self.presentedViewController != nil {
            dismiss(animated: true, completion: completion)
        } else {
            navigationController?.popViewController(animated: true)
            if let completion = completion {
                completion()
            }
        }
    }
    
    @IBAction func updatePaymentInformationFromSetting(sender: UIStoryboardSegue) {
        guard let paymentSettingTableViewController = sender.source as? PaymentSettingTableViewController else {
            return
        }
        
        paymentAmount = paymentSettingTableViewController.currentAmount
        paymentCurrencyCode = paymentSettingTableViewController.currentCurrencyCode
        usesCapabilityDataForPaymentMethods = paymentSettingTableViewController.usesCapabilityDataForPaymentMethods
        allowedPaymentMethods = Array(paymentSettingTableViewController.allowedPaymentMethods)
    }
    
    @IBAction func codePathModeChangedHandler(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            currentCodePathMode = .code
        } else {
            currentCodePathMode = .storyboard
        }
    }
}
