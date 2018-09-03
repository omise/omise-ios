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

protocol PaymentSourceCreator {
    var coordinator: PaymentCreatorTrampoline? { get }
    
    var client: Client? { get set }
    var paymentAmount: Int64? { get set }
    var paymentCurrency: Currency? { get set }
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
            waringMessageMessage = "Please setting the public key before request token or source."
        } else if self.paymentAmount == nil || self.paymentCurrency == nil {
            if #available(iOS 10.0, *) {
                os_log("Missing payment information - %{private}d %{private}@", log: uiLogObject, type: .error, self.paymentAmount ?? 0, self.paymentCurrency?.code ?? "-")
            }
            waringMessageTitle = "Missing payment information."
            waringMessageMessage = "Please setting both of the payment information (amount and currency) before request source/"
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
    
    func requestCreateSource(_ sourceType: PaymentInformation) {
        guard validateRequiredProperties(), let client = self.client, let amount = paymentAmount, let currency = paymentCurrency else {
            return
        }
        
        client.sendRequest(Request<Source>(sourceType: sourceType, amount: amount, currency: currency)) { (result) in
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
                                            didCreateSource source: Source)
    func paymentChooserViewController(_ paymentChooserViewController: PaymentChooserViewController,
                                      didCreateToken token: Token)
    func paymentChooserViewController(_ paymentChooserViewController: PaymentChooserViewController,
                                            didFailedToCreateSourceWithError error: Error)
    func paymentChooserViewControllerDidCancel(_ paymentChooserViewController: PaymentChooserViewController)
}


@objc(OMSPaymentChooserViewController)
public class PaymentChooserViewController: AdaptableStaticTableViewController<PaymentChooserOption>, PaymentSourceCreator {
    
    /// Omise public key for calling tokenization API.
    @objc public var publicKey: String? {
        didSet {
            guard let publicKey = publicKey else {
                if #available(iOS 10.0, *) {
                    os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
                }
                assertionFailure("Missing public key information. Please setting the public key before request token.")
                return
            }
            
            self.client = Client(publicKey: publicKey)
        }
    }
    
    var client: Client?
    public var paymentAmount: Int64?
    public var paymentCurrency: Currency?
    
    let coordinator: PaymentCreatorTrampoline? = PaymentCreatorTrampoline()
    
    weak var delegate: PaymentChooserViewControllerDelegate?
    
    @objc public var showsCreditCardPayment: Bool = true
    @objc public var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentChooserViewController.defaultAvailablePaymentMethods {
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
            controller.client = self.client
            controller.paymentAmount = self.paymentAmount
            controller.paymentCurrency = self.paymentCurrency
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.installmentBrand })
            controller.coordinator = self.coordinator
            controller.client = self.client
            controller.paymentAmount = self.paymentAmount
            controller.paymentCurrency = self.paymentCurrency
        case (_, let controller as EContextInformationInputViewController):
            controller.coordinator = self.coordinator
            controller.client = self.client
            controller.paymentAmount = self.paymentAmount
            controller.paymentCurrency = self.paymentCurrency
        default:
            break
        }
        
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch element(forUIIndexPath: indexPath) {
        case .alipay:
            requestCreateSource(.alipay)
        case .tescoLotus:
            requestCreateSource(.billPayment(.tescoLotus))
        default:
            break
        }
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
}

extension PaymentChooserViewController: PaymentCreatorTrampolineDelegate {
    func paymentCreatorTrampoline(_ trampoline: PaymentCreatorTrampoline, isRequestedToHandleCreatedSource source: Source) {
        delegate?.paymentChooserViewController(self, didCreateSource: source)
    }
    
    func paymentCreatorTrampoline(_ trampoline: PaymentCreatorTrampoline, isRequestedToHandleError error: Error) {
        delegate?.paymentChooserViewController(self, didFailedToCreateSourceWithError: error)
    }
    
    func paymentCreatorTrampolineIsRequestedToCancel(_ trampoline: PaymentCreatorTrampoline) {
        delegate?.paymentChooserViewControllerDidCancel(self)
    }
    
}

extension PaymentChooserViewController: CreditCardFormViewControllerDelegate {
    public func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        delegate?.paymentChooserViewController(self, didCreateToken: token)
    }
    
    public func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        delegate?.paymentChooserViewController(self, didFailedToCreateSourceWithError: error)
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

