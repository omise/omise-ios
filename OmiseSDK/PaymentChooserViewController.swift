import UIKit
import os


protocol PaymentCreatorTrampolineDelegate: AnyObject {
    func paymentCreatorTrampoline(_ trampoline: PaymentCreatorTrampoline, isRequestedToHandleCreatedSource source: Source)
    func paymentCreatorTrampoline(_ trampoline: PaymentCreatorTrampoline, isRequestedToHandleError error: Error)
    func paymentCreatorTrampolineIsRequestedToCancel(_ trampoline: PaymentCreatorTrampoline)
}

class PaymentCreatorTrampoline {
    weak var delegate: PaymentCreatorTrampolineDelegate?
    func handleCreatedSource(_ source: Source) {
        delegate?.paymentCreatorTrampoline(self, isRequestedToHandleCreatedSource: source)
    }
    
    func handleFailedError(_ error: Error) {
        delegate?.paymentCreatorTrampoline(self, isRequestedToHandleError: error)
    }
    
    func requestToCancel() {
        delegate?.paymentCreatorTrampolineIsRequestedToCancel(self)
    }
    
}

protocol PaymentSourceCreator: AnyObject {
    var coordinator: PaymentCreatorTrampoline? { get }
    
    var client: Client? { get set }
    var paymentAmount: Int64? { get set }
    var paymentCurrency: Currency? { get set }
}


let defaultPaymentChooserUIPrimaryColor = #colorLiteral(red:0.24, green:0.25, blue:0.3, alpha:1)
let defaultPaymentChooserUISecondaryColor = #colorLiteral(red:0.89, green:0.91, blue:0.93, alpha:1)


protocol PaymentSourceChooserUI: AnyObject {
    var preferredPrimaryColor: UIColor? { get set }
    var preferredSecondaryColor: UIColor? { get set }
}

extension PaymentSourceChooserUI {
    var currentPrimaryColor: UIColor {
        return preferredPrimaryColor ?? defaultPaymentChooserUIPrimaryColor
    }
    
    var currentSecondaryColor: UIColor {
        return preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
    }
}


extension PaymentSourceCreator where Self: UIViewController {
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
            waringMessageMessage = "Please set both of the payment information (amount and currency) before request source/"
        } else {
            return true
        }
        
        #if DEBUG
        let alertController = UIAlertController(title: waringMessageTitle, message: waringMessageMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        #endif
        assertionFailure("\(waringMessageTitle): \(waringMessageMessage)")
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
                self.coordinator?.handleCreatedSource(source)
            case .fail(let error):
                self.coordinator?.handleFailedError(error)
            }
        }
    }
}


public enum PaymentChooserOption: StaticElementIterable, Equatable {
    case creditCard
    case installment
    case internetBanking
    case tescoLotus
    case conbini
    case payEasy
    case netBanking
    case alipay
    
    public static var allCases: [PaymentChooserOption] {
        return [
            .creditCard,
            .installment,
            .internetBanking,
            .tescoLotus,
            .conbini,
            .payEasy,
            .netBanking,
            .alipay,
        ]
    }
}

public protocol PaymentChooserViewControllerDelegate: AnyObject {
    func paymentChooserViewController(_ paymentChooserViewController: PaymentChooserViewController,
                                      didCreatePayment payment: Payment)
    func paymentChooserViewController(_ paymentChooserViewController: PaymentChooserViewController,
                                      didFailWithError error: Error)
    func paymentChooserViewControllerDidCancel(_ paymentChooserViewController: PaymentChooserViewController)
}


public enum Payment {
    case token(Token)
    case source(Source)
}


@objc(OMSPaymentChooserViewController)
public class PaymentChooserViewController: AdaptableStaticTableViewController<PaymentChooserOption>, PaymentSourceCreator, PaymentSourceChooserUI {
    /// Omise public key for calling tokenization API.
    @objc public var publicKey: String? {
        didSet {
            guard let publicKey = publicKey else {
                if #available(iOS 10.0, *) {
                    os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
                }
                assertionFailure("Missing public key information. Please set the public key before request token.")
                return
            }
            
            self.client = Client(publicKey: publicKey)
        }
    }
    
    var client: Client?
    public var paymentAmount: Int64?
    public var paymentCurrency: Currency?
    
    @IBOutlet var paymentMethodNameLables: [UILabel]!
    @IBOutlet var redirectMethodIconImageView: [UIImageView]!
    
    let coordinator: PaymentCreatorTrampoline? = PaymentCreatorTrampoline()
    
    public weak var delegate: PaymentChooserViewControllerDelegate?
    
    @IBOutlet var errorBannerView: UIView!
    @IBOutlet var errorMessageLabel: UILabel!
    
    @IBInspectable @objc public var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    @IBInspectable @objc public var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    @objc public var showsCreditCardPayment: Bool = true
    @objc public var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentChooserViewController.defaultAvailablePaymentMethods + [OMSSourceTypeValue.eContext] {
        didSet {
            showingValues = PaymentChooserOption.allCases.filter({
                switch $0 {
                case .creditCard:
                    return showsCreditCardPayment
                case .installment:
                    return allowedPaymentMethods.hasInstallmentSource
                case .internetBanking:
                    return allowedPaymentMethods.hasInternetBankingSource
                case .tescoLotus:
                    return allowedPaymentMethods.hasTescoLotusSource
                case .conbini, .payEasy, .netBanking:
                    return allowedPaymentMethods.hasEContextSource
                case .alipay:
                    return allowedPaymentMethods.hasAlipaySource
                }
            })
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator?.delegate = self
        
        applyPrimaryColor()
        applySecondaryColor()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        showingValues = PaymentChooserOption.allCases.filter({
            switch $0 {
            case .creditCard:
                return showsCreditCardPayment
            case .installment:
                return allowedPaymentMethods.hasInstallmentSource
            case .internetBanking:
                return allowedPaymentMethods.hasInternetBankingSource
            case .tescoLotus:
                return allowedPaymentMethods.hasTescoLotusSource
            case .conbini, .payEasy, .netBanking:
                return allowedPaymentMethods.hasEContextSource
            case .alipay:
                return allowedPaymentMethods.hasAlipaySource
            }
        })
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
            controller.delegate = self
            controller.publicKey = self.publicKey
        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.internetBankingSource })
            controller.coordinator = self.coordinator
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.installmentBrand })
            controller.coordinator = self.coordinator
        case (_, let controller as EContextInformationInputViewController):
            controller.coordinator = self.coordinator
            controller.paymentAmount = 5000
            controller.paymentCurrency = .jpy
            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(element(forUIIndexPath:)) {
                switch element {
                case .conbini:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.convenience-store.navigation-item.title",
                        bundle: Bundle.omiseSDKBundle, value: "Convenience Store",
                        comment: "A navigaiton title for the EContext screen when the `Convenience Store` is selected"
                    )
                case .netBanking:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.netbanking.navigation-item.title",
                        bundle: Bundle.omiseSDKBundle, value: "Netbanking",
                        comment: "A navigaiton title for the EContext screen when the `Netbanking` is selected"
                    )
                case .payEasy:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.pay-easy.navigation-item.title",
                        bundle: Bundle.omiseSDKBundle, value: "Pay-easy",
                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
                    )
                default: break
                }
            }
        default: break
        }
        
        if let paymentSourceCreator = segue.destination as? PaymentSourceCreator {
            paymentSourceCreator.client = self.client
            paymentSourceCreator.paymentAmount = self.paymentAmount
            paymentSourceCreator.paymentCurrency = self.paymentCurrency
        }
        if let paymentShourceChooserUI = segue.destination as? PaymentSourceChooserUI {
            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setShowsErrorBanner(false)
        
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let payment: PaymentInformation
        
        switch element(forUIIndexPath: indexPath) {
        case .alipay:
            payment = .alipay
        case .tescoLotus:
            payment = .billPayment(.tescoLotus)
        default:
            return
        }
        
        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        requestCreateSource(payment, completionHandler: { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        })
    }
    
    public override func staticIndexPath(forValue value: PaymentChooserOption) -> IndexPath {
        switch value {
        case .creditCard:
            return IndexPath(row: 0, section: 0)
        case .installment:
            return IndexPath(row: 1, section: 0)
        case .internetBanking:
            return IndexPath(row: 2, section: 0)
        case .tescoLotus:
            return IndexPath(row: 3, section: 0)
        case .conbini:
            return IndexPath(row: 4, section: 0)
        case .payEasy:
            return IndexPath(row: 5, section: 0)
        case .netBanking:
            return IndexPath(row: 6, section: 0)
        case .alipay:
            return IndexPath(row: 7, section: 0)
        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        paymentMethodNameLables.forEach({
            $0.textColor = currentPrimaryColor
        })
    }
    
    private func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        
        redirectMethodIconImageView.forEach({
            $0.tintColor = currentSecondaryColor
        })
    }
    
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
}

extension PaymentChooserViewController: PaymentCreatorTrampolineDelegate {
    func paymentCreatorTrampoline(_ trampoline: PaymentCreatorTrampoline, isRequestedToHandleCreatedSource source: Source) {
        delegate?.paymentChooserViewController(self, didCreatePayment: Payment.source(source))
    }
    
    func paymentCreatorTrampoline(_ trampoline: PaymentCreatorTrampoline, isRequestedToHandleError error: Error) {
        delegate?.paymentChooserViewController(self, didFailWithError: error)
        setShowsErrorBanner(true)
    }
    
    func paymentCreatorTrampolineIsRequestedToCancel(_ trampoline: PaymentCreatorTrampoline) {
        delegate?.paymentChooserViewControllerDidCancel(self)
    }
    
}

extension PaymentChooserViewController: CreditCardFormViewControllerDelegate {
    public func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        delegate?.paymentChooserViewController(self, didCreatePayment: Payment.token(token))
    }
    
    public func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        delegate?.paymentChooserViewController(self, didFailWithError: error)
    }
    
    public func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
        delegate?.paymentChooserViewControllerDidCancel(self)
    }
}


extension Array where Element == OMSSourceTypeValue {
    public var hasInternetBankingSource: Bool {
        return self.contains(where: { $0.isInternetBankingSource })
    }
    
    public var hasInstallmentSource: Bool {
        return self.contains(where: { $0.isInstallmentSource })
    }
    
    public var hasTescoLotusSource: Bool {
        return self.contains(.billPaymentTescoLotus)
    }
    
    public var hasAlipaySource: Bool {
        return self.contains(.alipay)
    }
    
    public var hasEContextSource: Bool {
        return self.contains(.eContext)
    }
}


extension PaymentChooserViewController {
    public static let defaultAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
        .alipay,
        .billPaymentTescoLotus,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
    ]
    
    public static let internetBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
    ]
    
    public static let installmentsBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
    ]
    
    public static let billPaymentAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .billPaymentTescoLotus,
    ]
    
    public static let barcodeAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .barcodeAlipay,
    ]
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


