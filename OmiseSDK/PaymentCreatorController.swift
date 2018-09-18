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
    
    @objc public var showsCreditCardPayment: Bool = true {
        didSet {
            paymentChooserViewController.showsCreditCardPayment = showsCreditCardPayment
        }
    }
    @objc public var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentCreatorController.defaultAvailablePaymentMethods + [OMSSourceTypeValue.eContext] {
        didSet {
            paymentChooserViewController.allowedPaymentMethods = allowedPaymentMethods
        }
    }
    
    public var preferredPrimaryColor: UIColor?
    public var preferredSecondaryColor: UIColor?
    
    public weak var paymentDelegate: PaymentCreatorControllerDelegate?
    
    private let paymentSourceCreatorFlowSession = PaymentSourceCreatorFlowSession()
    
    private var paymentChooserViewController: PaymentChooserViewController {
        return topViewController as! PaymentChooserViewController
    }
    
    private var noticeViewHeightConstraint: NSLayoutConstraint!
    private let displayingNoticeView: NoticeView = {
        let bundle = Bundle.omiseSDKBundle
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: bundle)
        let noticeView = noticeViewNib.instantiate(withOwner: nil, options: nil).first as! NoticeView
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        return noticeView
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
    
    public init() {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: Bundle.omiseSDKBundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PaymentChooserController")
        
        guard let paymentChooserViewController = viewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        
        super.init(rootViewController: paymentChooserViewController)
      
        initializeWithPaymentChooserViewController(paymentChooserViewController)
    }
    
    @available(iOS, unavailable)
    public override init(rootViewController: UIViewController) {
        guard let rootViewController = rootViewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        super.init(rootViewController: rootViewController)

        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override var viewControllers: [UIViewController] {
        willSet {
            if !(viewControllers.first is PaymentChooserViewController) {
                preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
            }
        }
    }
    
    private func initializeWithPaymentChooserViewController(_ viewController: PaymentChooserViewController) {
        viewController.preferredPrimaryColor = preferredPrimaryColor
        viewController.preferredSecondaryColor = preferredSecondaryColor
        
        viewController.flowSession = paymentSourceCreatorFlowSession
        viewController.allowedPaymentMethods = allowedPaymentMethods
        viewController.showsCreditCardPayment = showsCreditCardPayment
        paymentSourceCreatorFlowSession.delegate = self
        
        if #available(iOS 9.0, *) {
            noticeViewHeightConstraint = displayingNoticeView.heightAnchor.constraint(equalToConstant: 0)
        } else {
            noticeViewHeightConstraint = NSLayoutConstraint(item: displayingNoticeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        }
        noticeViewHeightConstraint.isActive = true
        
        let dismissErrorBannerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissErrorMessageBanner(_:)))
        displayingNoticeView.addGestureRecognizer(dismissErrorBannerTapGestureRecognizer)
    }
    
    override func displayErrorMessage(_ message: String, animated: Bool, sender: AnyObject) {
        displayingNoticeView.detailLabel.text = message
        view.insertSubview(self.displayingNoticeView, belowSubview: navigationBar)
        
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                displayingNoticeView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                displayingNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                displayingNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
        } else {
            let views = ["displayingNoticeView": displayingNoticeView] as [String: UIView]
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "|[displayingNoticeView]|", options: [], metrics: nil, views: views) +
                [ NSLayoutConstraint(item: displayingNoticeView, attribute: .top, relatedBy: .equal, toItem: navigationBar, attribute: .bottom, multiplier: 1.0, constant: 0)]
            view.addConstraints(constraints)
        }
        
        noticeViewHeightConstraint.isActive = true
        view.layoutIfNeeded()
        
        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = false
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration) + 0.07, delay: 0.0, options: [.layoutSubviews], animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    override func dismissErrorMessage(animated: Bool, sender: AnyObject) {
        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(
                withDuration: TimeInterval(UINavigationControllerHideShowBarDuration), delay: 0.0,
                options: [.layoutSubviews], animations: animationBlock,
                completion: { _ in
                    self.displayingNoticeView.removeFromSuperview()
            })
        } else {
            animationBlock()
            self.displayingNoticeView.removeFromSuperview()
        }
    }
    
    @objc func dismissErrorMessageBanner(_ sender: AnyObject) {
        dismissErrorMessage(animated: true, sender: sender)
    }
}


extension PaymentCreatorController : PaymentSourceCreatorFlowSessionDelegate {
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentSourceCreatorFlowSession, didCreatedSource source: Source) {
        paymentDelegate?.paymentCreatorController(self, didCreatePayment: Payment.source(source))
    }
    
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentSourceCreatorFlowSession, didFailWithError error: Error) {
        displayErrorMessage(error.localizedDescription, animated: true, sender: self)
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


class NoticeView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!

}
