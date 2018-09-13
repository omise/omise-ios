import Foundation
import os


let defaultPaymentChooserUIPrimaryColor = #colorLiteral(red:0.24, green:0.25, blue:0.3, alpha:1)
let defaultPaymentChooserUISecondaryColor = #colorLiteral(red:0.89, green:0.91, blue:0.93, alpha:1)


internal protocol PaymentSourceCreatorFlowSessionDelegate : AnyObject {
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentSourceCreatorFlowSession,
                                   didCreatedSource source: Source)
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentSourceCreatorFlowSession,
                                   didFailWithError error: Error)
}

internal class PaymentSourceCreatorFlowSession {
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    weak var delegate: PaymentSourceCreatorFlowSessionDelegate?
    
    func validateRequiredProperties() -> Bool {
        let waringMessageTitle: String
        let waringMessageMessage: String
        
        if self.client == nil {
            if #available(iOS 10.0, *) {
                os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.client ?? "")
            }
            waringMessageTitle = "Missing public key information."
            waringMessageMessage = "Please set the public key before request token or source."
        } else if self.paymentAmount == nil || self.paymentCurrency == nil {
            if #available(iOS 10.0, *) {
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
    
    func requestCreateSource(_ sourceType: PaymentInformation, completionHandler: ((RequestResult<Source>) -> Void)?) {
        guard validateRequiredProperties(), let client = self.client,
            let amount = paymentAmount, let currency = paymentCurrency else {
                return
        }
        
        client.sendRequest(Request<Source>(sourceType: sourceType, amount: amount, currency: currency)) { (result) in
            defer {
                DispatchQueue.main.async {
                    completionHandler?(result)
                }
            }
            switch result {
            case .success(let source):
                self.delegate?.paymentCreatorFlowSession(self, didCreatedSource: source)
            case .fail(let error):
                self.delegate?.paymentCreatorFlowSession(self, didFailWithError: error)
            }
        }
    }
}

protocol PaymentSourceChooser {
    var flowSession: PaymentSourceCreatorFlowSession? { get set }
}

extension PaymentChooserUI {
    var currentPrimaryColor: UIColor {
        return preferredPrimaryColor ?? defaultPaymentChooserUIPrimaryColor
    }
    
    var currentSecondaryColor: UIColor {
        return preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
    }
}

public protocol ErrorDisplayableUI: AnyObject {
    var errorBannerView: UIView! { get }
    var errorMessageLabel: UILabel! { get }
}

protocol PaymentFormUIController: ErrorDisplayableUI {
    var formLabels: [UILabel]! { get }
    var formFields: [OmiseTextField]! { get }
    var formFieldsAccessoryView: UIToolbar! { get }
    var gotoPreviousFieldBarButtonItem: UIBarButtonItem! { get }
    var gotoNextFieldBarButtonItem: UIBarButtonItem! { get }
    var doneEditingBarButtonItem: UIBarButtonItem! { get }
    
    var currentEditingTextField: OmiseTextField? { get set }
    
    var contentView: UIScrollView! { get }
    var hidingErrorBannerConstraint: NSLayoutConstraint! { get }
}


extension PaymentFormUIController where Self: UIViewController {
    func setShowsErrorBanner(_ showsErrorBanner: Bool, animated: Bool = true) {
        hidingErrorBannerConstraint.isActive = !showsErrorBanner
        
        let animationBlock = {
            self.errorBannerView.alpha = showsErrorBanner ? 1.0 : 0.0
            self.contentView.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration), delay: 0.0, options: [.layoutSubviews], animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    func updateInputAccessoryViewWithFirstResponder(_ firstResponder: OmiseTextField) {
        guard formFields.contains(firstResponder) else { return }
        
        currentEditingTextField = firstResponder
        gotoPreviousFieldBarButtonItem.isEnabled = firstResponder !== formFields.first
        gotoNextFieldBarButtonItem.isEnabled = firstResponder !== formFields.last
    }
    
    func gotoPreviousField() {
        guard let currentTextField = currentEditingTextField, let index = formFields.index(of: currentTextField) else {
            return
        }
        
        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        formFields[prevIndex].becomeFirstResponder()
    }
    
    func gotoNextField() {
        guard let currentTextField = currentEditingTextField, let index = formFields.index(of: currentTextField) else {
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


extension ErrorDisplayableUI where Self: UITableViewController {
    private func setShowsErrorBanner(_ showsErrorBanner: Bool, animated: Bool = true) {
        let animationBlock = {
            self.errorBannerView.alpha = showsErrorBanner ? 1.0 : 0.0
            
            let height: CGFloat
            if showsErrorBanner {
                let preferredHeight = self.errorBannerView.systemLayoutSizeFitting(
                    CGSize(width: self.view.bounds.width, height: 48.0),
                    withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority:
                    UILayoutPriority.fittingSizeLevel
                    ).height
                height = max(preferredHeight, 48.0)
            } else {
                height = 0.0
            }
            self.errorBannerView.frame.size.height = height
            self.tableView.tableHeaderView = self.errorBannerView
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration), delay: 0.0, options: [.layoutSubviews], animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    public func displayErrorMessage(_ errorMessage: String, animated: Bool) {
        errorMessageLabel.text = errorMessage
        setShowsErrorBanner(true, animated: animated)
    }
    
    public func dismissErrorBanner(animated: Bool) {
        setShowsErrorBanner(false, animated: animated)
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
    }
    
    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        
        formLabels.forEach({
            $0.textColor = currentSecondaryColor
        })
        formFields.forEach({
            $0.borderColor = currentSecondaryColor
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



