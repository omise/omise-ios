import Foundation
import os


let defaultPaymentChooserUIPrimaryColor = UIColor.body
let defaultPaymentChooserUISecondaryColor = UIColor.line


internal protocol PaymentCreatorFlowSessionDelegate : AnyObject {
    func paymentCreatorFlowSessionWillCreateSource(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession)
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession,
                                   didCreateToken token: Token)
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession,
                                   didCreatedSource source: Source)
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession,
                                   didFailWithError error: Error)
    func paymentCreatorFlowSessionDidCancel(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession)
}

internal class PaymentCreatorFlowSession {
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    weak var delegate: PaymentCreatorFlowSessionDelegate?
    
    func validateRequiredProperties() -> Bool {
        let waringMessageTitle: String
        let waringMessageMessage: String
        
        if self.client == nil {
            if #available(iOSApplicationExtension 10.0, *) {
                os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.client ?? "")
            }
            waringMessageTitle = "Missing public key information."
            waringMessageMessage = "Please set the public key before request token or source."
        } else if self.paymentAmount == nil || self.paymentCurrency == nil {
            if #available(iOSApplicationExtension 10.0, *) {
                os_log("Missing payment information - %{private}d %{private}@", log: uiLogObject, type: .error, self.paymentAmount ?? 0, self.paymentCurrency?.code ?? "-")
            }
            waringMessageTitle = "Missing payment information."
            waringMessageMessage = "Please set both of the payment information (amount and currency) before request source"
        } else {
            return true
        }
        
        #if DEBUG
        let alertController = UIAlertController(title: waringMessageTitle, message: waringMessageMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        #endif
        assertionFailure("\(waringMessageTitle) \(waringMessageMessage)")
        return false
    }
    
    func requestCreateSource(_ paymentInformation: PaymentInformation, completionHandler: ((RequestResult<Source>) -> Void)?) {
        guard validateRequiredProperties(), let client = self.client,
            let amount = paymentAmount, let currency = paymentCurrency else {
                return
        }
        
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("Request to create a new source", log: uiLogObject, type: .info)
        }
        
        delegate?.paymentCreatorFlowSessionWillCreateSource(self)
        client.send(Request<Source>(paymentInformation: paymentInformation, amount: amount, currency: currency)) { (result) in
            defer {
                DispatchQueue.main.async {
                    completionHandler?(result)
                }
            }
            
            switch result {
            case .success(let source):
                self.delegate?.paymentCreatorFlowSession(self, didCreatedSource: source)
            case .failure(let error):
                self.delegate?.paymentCreatorFlowSession(self, didFailWithError: error)
            }
        }
    }
    
    func requestToCancel() {
        delegate?.paymentCreatorFlowSessionDidCancel(self)
    }
}

extension PaymentCreatorFlowSession : CreditCardFormViewControllerDelegate {
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        delegate?.paymentCreatorFlowSession(self, didCreateToken: token)
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        delegate?.paymentCreatorFlowSession(self, didFailWithError: error)
    }
    
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {}
}

protocol PaymentSourceChooser {
    var flowSession: PaymentCreatorFlowSession? { get set }
}

extension PaymentChooserUI {
    var currentPrimaryColor: UIColor {
        return preferredPrimaryColor ?? defaultPaymentChooserUIPrimaryColor
    }
    
    var currentSecondaryColor: UIColor {
        return preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
    }
}

protocol PaymentFormUIController : AnyObject {
    var formLabels: [UILabel]! { get }
    var formFields: [OmiseTextField]! { get }
    var formFieldsAccessoryView: UIToolbar! { get }
    var gotoPreviousFieldBarButtonItem: UIBarButtonItem! { get }
    var gotoNextFieldBarButtonItem: UIBarButtonItem! { get }
    var doneEditingBarButtonItem: UIBarButtonItem! { get }
    
    var currentEditingTextField: OmiseTextField? { get set }
    
    var contentView: UIScrollView! { get }
}

extension UIViewController {
    @objc func displayErrorWith(title: String, message: String?, animated: Bool, sender: Any?) {
        let targetController = targetViewController(forAction: #selector(UIViewController.displayErrorWith(title:message:animated:sender:)), sender: sender)
        if let targetController = targetController {
            targetController.displayErrorWith(title: title, message: message, animated: animated, sender: sender)
        }
    }
    
    @objc func dismissErrorMessage(animated: Bool, sender: Any?) {
        let targetController = self.targetViewController(forAction: #selector(UIViewController.dismissErrorMessage(animated:sender:)), sender: sender)
        if let targetController = targetController {
            targetController.dismissErrorMessage(animated: animated, sender: sender)
        }
    }
}


extension PaymentFormUIController where Self: UIViewController {
    func updateInputAccessoryViewWithFirstResponder(_ firstResponder: OmiseTextField) {
        guard formFields.contains(firstResponder) else { return }
        
        currentEditingTextField = firstResponder
        gotoPreviousFieldBarButtonItem.isEnabled = firstResponder !== formFields.first
        gotoNextFieldBarButtonItem.isEnabled = firstResponder !== formFields.last
    }
    
    func gotoPreviousField() {
        guard let currentTextField = currentEditingTextField, let index = formFields.firstIndex(of: currentTextField) else {
            return
        }
        
        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        formFields[prevIndex].becomeFirstResponder()
    }
    
    func gotoNextField() {
        guard let currentTextField = currentEditingTextField, let index = formFields.firstIndex(of: currentTextField) else {
            return
        }
        
        let nextIndex = index + 1
        guard nextIndex < formFields.count else { return }
        formFields[nextIndex].becomeFirstResponder()
    }
    
    func doneEditing() {
        view.endEditing(true)
    }
}


extension PaymentFormUIController where Self: UIViewController & PaymentChooserUI {
    func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        formFields.forEach({
            $0.textColor = currentPrimaryColor
        })
        formLabels.forEach({
            $0.textColor = currentPrimaryColor
        })
    }
    
    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        
        formFields.forEach({
            $0.borderColor = currentSecondaryColor
            $0.placeholderTextColor = currentSecondaryColor
        })
    }
}


extension OMSSourceTypeValue {
    
    var installmentBrand: PaymentInformation.Installment.Brand? {
        switch self {
        case .installmentBAY:
            return .bay
        case .installmentFirstChoice:
            return .firstChoice
        case .installmentBBL:
            return .bbl
        case .installmentKTC:
            return .ktc
        case .installmentKBank:
            return .kBank
        default:
            return nil
        }
    }
    
    var isInstallmentSource: Bool {
        switch self {
        case .installmentBAY, .installmentFirstChoice, .installmentBBL, .installmentKTC, .installmentKBank:
            return true
        default:
            return false
        }
        
    }
    
    var internetBankingSource: PaymentInformation.InternetBanking? {
        switch self {
        case .internetBankingBAY:
            return .bay
        case .internetBankingKTB:
            return .ktb
        case .internetBankingSCB:
            return .scb
        case .internetBankingBBL:
            return .bbl
        default:
            return nil
        }
    }
    
    var isInternetBankingSource: Bool {
        switch self {
        case .internetBankingBAY, .internetBankingKTB, .internetBankingSCB, .internetBankingBBL:
            return true
        default:
            return false
        }
    }
}



