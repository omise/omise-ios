// swiftlint:disable file_length

import UIKit
import os

public protocol PaymentCreatorControllerDelegate: NSObjectProtocol {
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment)
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error)
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController)
}

public enum Payment {
    case token(Token)
    case source(Source)
}

public protocol PaymentChooserUI: AnyObject {
    var preferredPrimaryColor: UIColor? { get set }
    var preferredSecondaryColor: UIColor? { get set }
}

/// Drop-in UI flow controller that let user choose the payment method with the given payment options
public class PaymentCreatorController: UINavigationController {
    // swiftlint:disable:previous type_body_length

    enum PreconditionFailures: String {
        case paymentChooserViewcontrollerAsRoot =
                "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
    }

    /// Omise public key for calling tokenization API.
    public var publicKey: String? {
        didSet {
            guard let publicKey = publicKey else {
                os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
                assertionFailure("Missing public key information. Please set the public key before request token.")
                return
            }

            self.client = Client(publicKey: publicKey)
        }
    }

    /// Amount to create a Source payment
    public var paymentAmount: Int64? {
        didSet {
            paymentSourceCreatorFlowSession.paymentAmount = paymentAmount
        }
    }
    /// Currency to create a Source payment
    public var paymentCurrency: Currency? {
        didSet {
            paymentSourceCreatorFlowSession.paymentCurrency = paymentCurrency
        }
    }

    /// Boolean indicates that the form should show the Credit Card payment option or not
    public var showsCreditCardPayment = true {
        didSet {
            paymentChooserViewController.showsCreditCardPayment = showsCreditCardPayment
        }
    }

    /// Available Source payment options to let user to choose.
    /// The default value is the default available payment method for merchant in Thailand
    public var allowedPaymentMethods: [SourceTypeValue] = PaymentCreatorController.thailandDefaultAvailableSourceMethods {
        didSet {
            paymentChooserViewController.allowedPaymentMethods = allowedPaymentMethods
        }
    }

    /// A boolean flag to enables or disables automatic error handling.
    ///
    /// The controller will show an error alert in the UI if the value is true,
    /// otherwise the controller will ask its delegate.
    /// Defaults to `true`.
    public var handleErrors = true

    /// Delegate to receive CreditCardFormController result.
    public weak var paymentDelegate: PaymentCreatorControllerDelegate?

    var client: Client? {
        didSet {
            paymentSourceCreatorFlowSession.client = client
        }
    }

    private let paymentSourceCreatorFlowSession = PaymentCreatorFlowSession()

    private var paymentChooserViewController: PaymentChooserViewController {
        return viewControllers[0] as! PaymentChooserViewController // swiftlint:disable:this force_cast
    }

    private var noticeViewHeightConstraint: NSLayoutConstraint!
    private let displayingNoticeView: NoticeView = {
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: .omiseSDK)
        let noticeView = noticeViewNib.instantiate(withOwner: nil, options: nil).first as! NoticeView // swiftlint:disable:this force_cast
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        noticeView.backgroundColor = .error
        return noticeView
    }()

    @IBInspectable public var preferredPrimaryColor: UIColor?
    @IBInspectable public var preferredSecondaryColor: UIColor? {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13, *) {
                let appearance = UINavigationBarAppearance(barAppearance: navigationBar.standardAppearance)
                appearance.shadowColor = preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
                navigationBar.standardAppearance = appearance
            }
            #endif
        }
    }

    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    public static func makePaymentCreatorControllerWith(
        publicKey: String,
        amount: Int64,
        currency: Currency,
        allowedPaymentMethods: [SourceTypeValue],
        paymentDelegate: PaymentCreatorControllerDelegate?
    ) -> PaymentCreatorController {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: .omiseSDK)
        let paymentCreatorController = storyboard.instantiateViewController(
            withIdentifier: "PaymentCreatorController"
        ) as! PaymentCreatorController // swiftlint:disable:this force_cast
        paymentCreatorController.publicKey = publicKey
        paymentCreatorController.paymentAmount = amount
        paymentCreatorController.paymentCurrency = currency
        paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
        paymentCreatorController.paymentDelegate = paymentDelegate

        return paymentCreatorController
    }

    public init() {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: .omiseSDK)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PaymentChooserController")

        guard let paymentChooserViewController = viewController as? PaymentChooserViewController else {
            preconditionFailure(
                PreconditionFailures.paymentChooserViewcontrollerAsRoot.rawValue
            )
        }

        super.init(rootViewController: paymentChooserViewController)

        initializeWithPaymentChooserViewController(paymentChooserViewController)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure(
                PreconditionFailures.paymentChooserViewcontrollerAsRoot.rawValue
            )
            return nil
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure(
                PreconditionFailures.paymentChooserViewcontrollerAsRoot.rawValue
            )
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }

    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)

        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure(
                PreconditionFailures.paymentChooserViewcontrollerAsRoot.rawValue
            )
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }

    public override var viewControllers: [UIViewController] {
        willSet {
            if !(viewControllers.first is PaymentChooserViewController) {
                preconditionFailure(
                    PreconditionFailures.paymentChooserViewcontrollerAsRoot.rawValue
                )
            }
        }
    }

    public func applyPaymentMethods(from capability: Capability) {
        paymentChooserViewController.applyPaymentMethods(from: capability)
    }

    private func initializeWithPaymentChooserViewController(_ viewController: PaymentChooserViewController) {
        viewController.preferredPrimaryColor = preferredPrimaryColor
        viewController.preferredSecondaryColor = preferredSecondaryColor

        viewController.flowSession = paymentSourceCreatorFlowSession
        viewController.allowedPaymentMethods = allowedPaymentMethods
        viewController.showsCreditCardPayment = showsCreditCardPayment

        paymentSourceCreatorFlowSession.delegate = self

        noticeViewHeightConstraint = displayingNoticeView.heightAnchor.constraint(equalToConstant: 0)
        noticeViewHeightConstraint.isActive = true

        let dismissErrorBannerTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                            action: #selector(self.dismissErrorMessageBanner(_:)))
        displayingNoticeView.addGestureRecognizer(dismissErrorBannerTapGestureRecognizer)
    }

    /// Displays an error banner at the top of the UI with the given error message.
    ///
    /// - Parameters:
    ///   - title: Title message to be displayed in the banner
    ///   - message: Subtitle message to be displayed in the banner
    ///   - animated: Pass true to animate the presentation; otherwise, pass false
    ///   - sender: The object that initiated the request
    public override func displayErrorWith(title: String, message: String?, animated: Bool, sender: Any?) {
        displayingNoticeView.titleLabel.text = title
        displayingNoticeView.detailLabel.text = message
        view.insertSubview(self.displayingNoticeView, belowSubview: navigationBar)

        NSLayoutConstraint.activate([
            displayingNoticeView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            displayingNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displayingNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        noticeViewHeightConstraint.isActive = true
        view.layoutIfNeeded()

        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = false
            self.view.layoutIfNeeded()
            if #available(iOS 13, *) {
                self.topViewController?.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
            } else if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
            }
        }

        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration) + 0.07,
                           delay: 0.0,
                           options: [.layoutSubviews, .beginFromCurrentState],
                           animations: animationBlock)
        } else {
            animationBlock()
        }
    }

    override func dismissErrorMessage(animated: Bool, sender: Any?) {
        guard self.displayingNoticeView.superview != nil else {
            return
        }

        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = true
            self.view.layoutIfNeeded()
            if #available(iOS 13, *) {
                self.topViewController?.additionalSafeAreaInsets.top = 0
            } else if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.top = 0
            }
        }

        if animated {
            UIView.animate(
                withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                delay: 0.0,
                options: [.layoutSubviews],
                animations: animationBlock
            ) { _ in
                var isCompleted: Bool {
                    if #available(iOS 13, *) {
                        return self.topViewController?.additionalSafeAreaInsets.top == 0
                    } else if #available(iOS 11, *) {
                        return self.additionalSafeAreaInsets.top == 0
                    } else {
                        return true
                    }
                }
                guard isCompleted else { return }
                self.displayingNoticeView.removeFromSuperview()
            }
        } else {
            animationBlock()
            self.displayingNoticeView.removeFromSuperview()
        }
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        dismissErrorMessage(animated: false, sender: self)

        if let viewController = viewController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
        if let viewController = viewController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.pushViewController(viewController, animated: animated)
    }

    public override func popViewController(animated: Bool) -> UIViewController? {
        dismissErrorMessage(animated: false, sender: self)
        return super.popViewController(animated: animated)
    }

    public override func addChild(_ childController: UIViewController) {
        if let viewController = childController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
        if let viewController = childController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.addChild(childController)
    }

    // need to refactor loadView, removing super results in crash
    // swiftlint:disable:next prohibited_super_call
    public override func loadView() {
        super.loadView()

        view.backgroundColor = .background
        applyNavigationBarStyle(.shadow(color: preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor))
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if self.displayingNoticeView.superview != nil {
            coordinator.animate(alongsideTransition: { _ in
                if #available(iOS 13, *) {
                    self.additionalSafeAreaInsets.top = 0
                } else if #available(iOS 11, *) {
                    self.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
                }
            }, completion: nil)
        }
    }

    @objc func dismissErrorMessageBanner(_ sender: AnyObject) {
        dismissErrorMessage(animated: true, sender: sender)
    }
}

extension PaymentCreatorController: PaymentCreatorFlowSessionDelegate {
    func paymentCreatorFlowSessionWillCreateSource(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession) {
        dismissErrorMessage(animated: true, sender: self)
    }

    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didCreateToken token: Token) {
        os_log("Credit Card Form in Payment Createor - Request succeed %{private}@, trying to notify the delegate",
               log: uiLogObject,
               type: .default,
               token.id)

        if let paymentDelegate = self.paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreatePayment: Payment.token(token))
        }
    }

    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didCreatedSource source: Source) {
        os_log("Payment Creator Create Source Request succeed %{private}@, trying to notify the delegate",
               log: uiLogObject,
               type: .default,
               source.id)

        if let paymentDelegate = self.paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreatePayment: Payment.source(source))
            os_log("Payment Creator Created Source succeed delegate notified", log: uiLogObject, type: .default)
        } else {
            os_log("There is no Payment Creator delegate to notify about the created source", log: uiLogObject, type: .default)
        }
    }

    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didFailWithError error: Error) {
        if !handleErrors {
            os_log("Payment Creator Request failed %{private}@, automatically error handling turned off. Trying to notify the delegate",
                   log: uiLogObject,
                   type: .info,
                   error.localizedDescription)
            if let paymentDelegate = self.paymentDelegate {
                paymentDelegate.paymentCreatorController(self, didFailWithError: error)
                os_log("Payment Creator error handling delegate notified", log: uiLogObject, type: .default)
            } else {
                os_log("There is no Payment Creator delegate to notify about the error", log: uiLogObject, type: .default)
            }
        } else if let error = error as? OmiseError {
            displayErrorWith(title: error.bannerErrorDescription,
                             message: error.bannerErrorRecoverySuggestion,
                             animated: true,
                             sender: self)
        } else if let error = error as? LocalizedError {
            displayErrorWith(title: error.localizedDescription,
                             message: error.recoverySuggestion,
                             animated: true,
                             sender: self)
        } else {
            displayErrorWith(title: error.localizedDescription,
                             message: nil,
                             animated: true,
                             sender: self)
        }

        os_log("Payment Creator Request failed %{private}@, automatically error handling turned on.",
               log: uiLogObject,
               type: .default,
               error.localizedDescription)
    }

    func paymentCreatorFlowSessionDidCancel(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession) {
        os_log("Payment Creator dismissal requested. Asking the delegate what should the controler do", log: uiLogObject, type: .default)

        if let paymentDelegate = self.paymentDelegate {
            paymentDelegate.paymentCreatorControllerDidCancel(self)
        } else {
            os_log("Payment Creator dismissal requested but there is no delegate to ask. Ignore the request",
                   log: uiLogObject,
                   type: .default)
        }
    }
}

extension PaymentCreatorController {
    public static let thailandDefaultAvailableSourceMethods: [SourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingBBL,
        .mobileBankingSCB,
        .mobileBankingKBank,
        .mobileBankingBAY,
        .mobileBankingBBL,
        .mobileBankingKTB,
        .alipay,
        .billPaymentTescoLotus,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
        .installmentSCB,
        .installmentTTB,
        .installmentUOB,
        .promptPay,
        .trueMoney,
        .pointsCiti,
        .shopeePayJumpApp
    ]

    public static let japanDefaultAvailableSourceMethods: [SourceTypeValue] = [
        .eContext,
        .payPay
    ]

    public static let singaporeDefaultAvailableSourceMethods: [SourceTypeValue] = [
        .payNow,
        .shopeePayJumpApp
    ]

    public static let malaysiaDefaultAvailableSourceMethods: [SourceTypeValue] = [
        .fpx,
        .installmentMBB,
        .touchNGo,
        .grabPay,
        .boost,
        .shopeePayJumpApp,
        .maybankQRPay,
        .duitNowQR,
        .duitNowOBW
    ]

    public static let internetBankingAvailablePaymentMethods: [SourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingBBL
    ]

    // swiftlint:disable:next identifier_name
    public static let installmentsBankingAvailablePaymentMethods: [SourceTypeValue] = [
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentMBB,
        .installmentKTC,
        .installmentKBank,
        .installmentSCB,
        .installmentTTB,
        .installmentUOB
    ]

    public static let billPaymentAvailablePaymentMethods: [SourceTypeValue] = [
        .billPaymentTescoLotus
    ]

    public static let barcodeAvailablePaymentMethods: [SourceTypeValue] = [
        .barcodeAlipay
    ]

    public static let mobileBankingAvailablePaymentMethods: [SourceTypeValue] = [
        .mobileBankingSCB,
        .mobileBankingKBank,
        .mobileBankingBAY,
        .mobileBankingKTB
    ]
}

class NoticeView: UIView {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!

}
