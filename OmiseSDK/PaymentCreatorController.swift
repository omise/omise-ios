// swiftlint:disable file_length

import UIKit
import os

public protocol PaymentCreatorControllerDelegate: NSObjectProtocol {
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment)
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error)
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController)
}

@objc public protocol OMSPaymentCreatorControllerDelegate: NSObjectProtocol {
    @objc func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreateToken token: __OmiseToken)
    @objc func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreateSource source: __OmiseSource)
    @objc func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error)
    @objc optional func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController)
}

public enum Payment {
    case token(Token)
    case source(Source)
}

public protocol PaymentChooserUI: AnyObject {
    var preferredPrimaryColor: UIColor? { get set }
    var preferredSecondaryColor: UIColor? { get set }
}

// swiftlint:disable type_body_length
/// Drop-in UI flow controller that let user choose the payment method with the given payment options
@objc(OMSPaymentCreatorController)
public class PaymentCreatorController: UINavigationController {
    /// Omise public key for calling tokenization API.
    @objc public var publicKey: String? {
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
    
    /// Amount to create a Source payment
    @objc(paymentAmount) public var __paymentAmount: Int64 { // swiftlint:disable:this identifier_name
        get {
            return paymentAmount ?? 0
        }
        set {
            paymentAmount = newValue > 0 ? Int64(newValue) : nil
        }
    }
    
    /// Currency to create a Source payment
    @objc(paymentCurrencyCode) public var __paymentCurrencyCode: String? { // swiftlint:disable:this identifier_name
        get {
            return paymentCurrency?.code
        }
        set {
            paymentCurrency = newValue.map(Currency.init(code:))
        }
    }
    
    /// Boolean indicates that the form should show the Credit Card payment option or not
    @objc public var showsCreditCardPayment = true {
        didSet {
            paymentChooserViewController.showsCreditCardPayment = showsCreditCardPayment
        }
    }
    
    /// Available Source payment options to let user to choose.
    /// The default value is the default available payment method for merchant in Thailand
    @objc public var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentCreatorController.thailandDefaultAvailableSourceMethods {
        didSet {
            paymentChooserViewController.allowedPaymentMethods = allowedPaymentMethods
        }
    }
    
    /// A boolean flag to enables or disables automatic error handling.
    ///
    /// The controller will show an error alert in the UI if the value is true,
    /// otherwise the controller will ask its delegate.
    /// Defaults to `true`.
    @objc public var handleErrors = true
    
    /// Delegate to receive CreditCardFormController result.
    public weak var paymentDelegate: PaymentCreatorControllerDelegate?
    /// Delegate to receive CreditCardFormController result.
    @objc(paymentDelegate) public weak var __paymentDelegate: OMSPaymentCreatorControllerDelegate? // swiftlint:disable:this identifier_name

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
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: .module)
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
        allowedPaymentMethods: [OMSSourceTypeValue],
        paymentDelegate: PaymentCreatorControllerDelegate?
    ) -> PaymentCreatorController {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: .module)
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
    
    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    @objc(paymentCreatorControllerWithPublicKey:amount:currency:allowedPaymentMethods:paymentDelegate:)
    public static func __makePaymentCreatorViewControllerWith( // swiftlint:disable:this identifier_name
        publicKey: String,
        amount: Int64,
        currencyCode: String,
        allowedPaymentMethods: [OMSSourceTypeValue],
        paymentDelegate: OMSPaymentCreatorControllerDelegate
    ) -> PaymentCreatorController {
        let controller = PaymentCreatorController.makePaymentCreatorControllerWith(
            publicKey: publicKey,
            amount: amount,
            currency: Currency(code: currencyCode),
            allowedPaymentMethods: allowedPaymentMethods,
            paymentDelegate: nil)
        controller.__paymentDelegate = paymentDelegate
        return controller
    }

    public init() {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: .module)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PaymentChooserController")
        
        guard let paymentChooserViewController = viewController as? PaymentChooserViewController else {
            preconditionFailure(
                "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
            )
        }
        
        super.init(rootViewController: paymentChooserViewController)
        
        initializeWithPaymentChooserViewController(paymentChooserViewController)
    }
    
    @available(iOS, unavailable)
    public override init(rootViewController: UIViewController) {
        guard let rootViewController = rootViewController as? PaymentChooserViewController else {
            preconditionFailure(
                "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
            )
        }
        super.init(rootViewController: rootViewController)

        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure(
                "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
            )
            return nil
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure(
                "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
            )
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure(
                "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
            )
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override var viewControllers: [UIViewController] {
        willSet {
            if !(viewControllers.first is PaymentChooserViewController) {
                preconditionFailure(
                    "This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller"
                )
            }
        }
    }
    
    public func applyPaymentMethods(from capability: Capability) {
        paymentChooserViewController.applyPaymentMethods(from: capability)
    }
    
    @objc(applyPaymentMethodsFrom:)
    public func __applyPaymentMethods(from capability: __OmiseCapability) { // swiftlint:disable:this identifier_name
        applyPaymentMethods(from: capability.capability)
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
            UIView.animate(withDuration: TimeInterval(NavigationControllerHideShowBarDuration) + 0.07,
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
                withDuration: TimeInterval(NavigationControllerHideShowBarDuration),
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
    // swiftlint:disable prohibited_super_call
    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = .background
        
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance(barAppearance: navigationBar.standardAppearance)
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            appearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            let image = renderer.image { (context) in
                context.cgContext.setFillColor(UIColor.line.cgColor)
                context.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
            }
            appearance.shadowImage = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
                .withRenderingMode(.alwaysTemplate)
            appearance.shadowColor = preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
            navigationBar.standardAppearance = appearance
            
            let scrollEdgeAppearance = UINavigationBarAppearance(barAppearance: navigationBar.standardAppearance)
            appearance.shadowColor = preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
            navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
        #endif
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
        } else if let paymentDelegate = self.__paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreateToken: __OmiseToken(token: token))
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
        } else if let paymentDelegate = self.__paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreateSource: __OmiseSource(source: source))
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
            } else if let paymentDelegate = self.__paymentDelegate {
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
        } else if let paymentDidCancelDelegateMethod = self.__paymentDelegate?.paymentCreatorControllerDidCancel {
            paymentDidCancelDelegateMethod(self)
        } else {
            os_log("Payment Creator dismissal requested but there is no delegate to ask. Ignore the request",
                   log: uiLogObject,
                   type: .default)
        }
    }
}

extension PaymentCreatorController {
    public static let thailandDefaultAvailableSourceMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
        .mobileBankingSCB,
        .alipay,
        .billPaymentTescoLotus,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
        .installmentSCB,
        .promptPay,
        .trueMoney,
        .pointsCiti
    ]
    
    public static let japanDefaultAvailableSourceMethods: [OMSSourceTypeValue] = [
        .eContext
    ]
    
    public static let singaporeDefaultAvailableSourceMethods: [OMSSourceTypeValue] = [
        .payNow
    ]
    
    public static let malaysiaDefaultAvailableSourceMethods: [OMSSourceTypeValue] = [
        .fpx,
        .installmentEzypay
    ]

    public static let internetBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL
    ]
    
    // swiftlint:disable:next identifier_name
    public static let installmentsBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentEzypay,
        .installmentKTC,
        .installmentKBank,
        .installmentSCB
    ]
    
    public static let billPaymentAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .billPaymentTescoLotus
    ]
    
    public static let barcodeAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .barcodeAlipay
    ]

    public static let mobileBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .mobileBankingSCB
    ]
}

class NoticeView: UIView {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
}
