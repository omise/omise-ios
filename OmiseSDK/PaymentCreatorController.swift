import UIKit
import os


public protocol PaymentCreatorControllerDelegate: NSObjectProtocol {
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didCreatePayment payment: Payment)
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didFailWithError error: Error)
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController)
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


public enum Payment {
    case token(Token)
    case source(Source)
}

public protocol PaymentChooserUI: AnyObject {
    var preferredPrimaryColor: UIColor? { get set }
    var preferredSecondaryColor: UIColor? { get set }
}

public class PaymentCreatorController : UINavigationController {
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
    
    var client: Client? {
        didSet {
            paymentSourceCreatorFlowSession.client = client
        }
    }
    public var paymentAmount: Int64? {
        didSet {
            paymentSourceCreatorFlowSession.paymentAmount = paymentAmount
        }
    }
    public var paymentCurrency: Currency? {
        didSet {
            paymentSourceCreatorFlowSession.paymentCurrency = paymentCurrency
        }
    }
    
    public var preferredPrimaryColor: UIColor?
    public var preferredSecondaryColor: UIColor?
    
    public weak var paymentDelegate: PaymentCreatorControllerDelegate?
    
    private let paymentSourceCreatorFlowSession = PaymentSourceCreatorFlowSession()
    
    private let displayingNoticeView: UIView = {
        let bundle = Bundle.omiseSDKBundle
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: bundle)
        return noticeViewNib.instantiate(withOwner: nil, options: nil).first as! UIView
    }()
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let viewController = viewController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
        if let viewController = viewController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func addChildViewController(_ childController: UIViewController) {
        if let viewController = childController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
        if let viewController = childController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.addChildViewController(childController)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        if let rootViewController = rootViewController as? PaymentChooserUI {
            rootViewController.preferredPrimaryColor = preferredPrimaryColor
            rootViewController.preferredSecondaryColor = preferredSecondaryColor
        }
        
        if let viewController = rootViewController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        
        self.paymentSourceCreatorFlowSession.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let rootViewController = topViewController as? PaymentChooserUI {
            rootViewController.preferredPrimaryColor = preferredPrimaryColor
            rootViewController.preferredSecondaryColor = preferredSecondaryColor
        }
        
        if let viewController = topViewController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }

        self.paymentSourceCreatorFlowSession.delegate = self
    }
}


extension PaymentCreatorController : PaymentSourceCreatorFlowSessionDelegate {
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentSourceCreatorFlowSession, didCreatedSource source: Source) {
        paymentDelegate?.paymentCreatorController(self, didCreatePayment: Payment.source(source))
    }
    
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentSourceCreatorFlowSession, didFailWithError error: Error) {
        paymentDelegate?.paymentCreatorController(self, didFailWithError: error)
    }
}


extension PaymentCreatorController {
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


public class NoticeView: UIView {
    
    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var detailLabel: UILabel!

}
