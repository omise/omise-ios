import UIKit

class ChoosePaymentCoordinator: NSObject, ViewAttachable {
    let client: Client
    let amount: Int64
    let currency: String
    let currentCountry: Country?
    let handleErrors: Bool

    enum ResultState {
        case cancelled
        case selectedPaymentMethod(PaymentMethod)
    }
    
    weak var choosePaymentMethodDelegate: ChoosePaymentMethodDelegate?
    weak var rootViewController: UIViewController?

    var errorViewHeightConstraint: NSLayoutConstraint?
    let errorView: NoticeView = {
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: .omiseSDK)
        let noticeView = noticeViewNib.instantiate(withOwner: nil, options: nil).first as! NoticeView // swiftlint:disable:this force_cast
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        noticeView.backgroundColor = .error
        return noticeView
    }()

    init(client: Client, amount: Int64, currency: String, currentCountry: Country?, handleErrors: Bool) {
        self.client = client
        self.amount = amount
        self.currency = currency
        self.currentCountry = currentCountry
        self.handleErrors = handleErrors
        super.init()

        self.setupErrorView()
    }

    /// Creates SelectPaymentController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - allowedPaymentMethods: List of Payment Methods to be presented in the list if `usePaymentMethodsFromCapability` is `false`
    ///   - allowedCardPayment: Shows credit card payment option if `true` and `usePaymentMethodsFromCapability` is `false`
    ///   - usePaymentMethodsFromCapability: If `true`then it loads list of Payment Methods from Capability API and ignores previous parameters
    ///   - delegate: Payment method delegate
    func createChoosePaymentMethodController(
        allowedPaymentMethods paymentMethods: [SourceType] = [],
        allowedCardPayment isCardEnabled: Bool = true,
        usePaymentMethodsFromCapability useCapability: Bool,
        delegate: ChoosePaymentMethodDelegate
    ) -> SelectPaymentController {
        let viewModel = SelectPaymentMethodViewModel(client: client, delegate: self)
        if useCapability {
            viewModel.setupCapability()
        } else {
            viewModel.setupAllowedPaymentMethods(paymentMethods, isCardEnabled: isCardEnabled)
        }

        let listController = SelectPaymentController(viewModel: viewModel)
        listController.attach(self)

        self.choosePaymentMethodDelegate = delegate
        self.rootViewController = listController

        return listController
    }

    /// Creates CreditCardController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - delegate: Payment method delegate
    func createCreditCardPaymentController(delegate: ChoosePaymentMethodDelegate) -> CreditCardPaymentController {
        let viewController = createCreditCardPaymentController()
        viewController.attach(self)

        self.choosePaymentMethodDelegate = delegate
        self.rootViewController = viewController

        return viewController
    }

    /// Creates Credit Carc Payment screen and attach current flow object inside created controller to be deallocated together
    func createCreditCardPaymentController() -> CreditCardPaymentController {
        let viewModel = CreditCardPaymentViewModel(currentCountry: currentCountry, delegate: self)
        let viewController = CreditCardPaymentController(nibName: nil, bundle: .omiseSDK)
        viewController.viewModel = viewModel
        viewController.title = PaymentMethod.creditCard.localizedTitle
        return viewController
    }

    /// Creates Mobile Banking screen and attach current flow object inside created controller to be deallocated together
    func createMobileBankingController() -> SelectPaymentController {
        let viewModel = SelectSourceTypePaymentViewModel(
            title: PaymentMethod.mobileBanking.localizedTitle,
            sourceTypes: SourceType.mobileBanking,
            delegate: self
        )

        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Mobile Banking screen and attach current flow object inside created controller to be deallocated together
    func createInternetBankingController() -> SelectPaymentController {
        let viewModel = SelectSourceTypePaymentViewModel(
            title: PaymentMethod.internetBanking.localizedTitle,
            sourceTypes: SourceType.internetBanking,
            delegate: self
        )

        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Installement screen and attach current flow object inside created controller to be deallocated together
    func createInstallmentController() -> SelectPaymentController {
        let viewModel = SelectSourceTypePaymentViewModel(
            title: PaymentMethod.installment.localizedTitle,
            sourceTypes: SourceType.installments,
            delegate: self
        )

        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Installement screen and attach current flow object inside created controller to be deallocated together
    func createInstallmentTermsController(sourceType: SourceType) -> SelectPaymentController {
        let viewModel = SelectInstallmentTermsViewModel(sourceType: sourceType, delegate: self)
        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Atome screen and attach current flow object inside created controller to be deallocated together
    func createAtomeController() -> AtomePaymentInputsFormController {
        let viewModel = AtomePaymentFormViewModel(amount: amount, currentCountry: currentCountry, delegate: self)
        let viewController = AtomePaymentInputsFormController(viewModel: viewModel)
        viewController.title = SourceType.atome.localizedTitle
        return viewController
    }

    /// Creates EContext screen and attach current flow object inside created controller to be deallocated together
    func createEContextController(title: String) -> EContextPaymentFormController {
        let viewController = EContextPaymentFormController(nibName: nil, bundle: .omiseSDK)
        viewController.title = title
        viewController.delegate = self
        return viewController
    }

    /// Creates FPX screen and attach current flow object inside created controller to be deallocated together
    func createFPXController() -> FPXPaymentFormController {
        let viewController = FPXPaymentFormController(nibName: nil, bundle: .omiseSDK)
        viewController.title = SourceType.fpx.localizedTitle
        viewController.delegate = self
        return viewController
    }

    /// Creates FPX Banks screen and attach current flow object inside created controller to be deallocated together
    func createFPXBanksController(email: String?) -> SelectPaymentController {
        let fpx = client.latestLoadedCapability?.paymentMethods.first { $0.name == SourceType.fpx.rawValue }
        let banks: [Capability.PaymentMethod.Bank] = Array(fpx?.banks ?? [])
        let viewModel = SelectFPXBankViewModel(email: email, banks: banks, delegate: self)
        let listController = SelectPaymentController(viewModel: viewModel)
        
        listController.customizeCellAtIndexPathClosure = { [banks] cell, indexPath in
            guard let bank = banks.at(indexPath.row) else { return }
            if !bank.isActive {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.contentView.alpha = 0.5
                cell.isUserInteractionEnabled = false
            }
        }
        return listController
    }

    /// Creates Installement screen and attach current flow object inside created controller to be deallocated together
    func createDuitNowOBWBanksController() -> SelectPaymentController {
        let banks = Source.Payment.DuitNowOBW.Bank.allCases.sorted {
            $0.localizedTitle.localizedCompare($1.localizedTitle) == .orderedAscending
        }

        let viewModel = SelectDuitNowOBWBankViewModel(banks: banks, delegate: self)
        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Installement screen and attach current flow object inside created controller to be deallocated together
    func createTrueMoneyWalletController() -> TrueMoneyPaymentFormController {
        let viewController = TrueMoneyPaymentFormController(nibName: nil, bundle: .omiseSDK)
        viewController.delegate = self
        return viewController
    }
}

extension ChoosePaymentCoordinator: FPXPaymentFormControllerDelegate {
    func fpxDidCompleteWith(email: String?, completion: @escaping () -> Void) {
        navigate(to: createFPXBanksController(email: email))
    }
}

extension ChoosePaymentCoordinator: CreditCardPaymentDelegate {
    func didSelectCardPayment(_ card: CreateTokenPayload.Card, completion: @escaping () -> Void) {
        processPayment(card, completion: completion)
    }

    func didCancelCardPayment() {
        didCancelPayment()
    }
}
extension ChoosePaymentCoordinator: SelectPaymentMethodDelegate {

    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod, completion: @escaping () -> Void) {
        if paymentMethod.requiresAdditionalDetails {
            switch paymentMethod {
            case .mobileBanking:
                navigate(to: createMobileBankingController())
            case .internetBanking:
                navigate(to: createInternetBankingController())
            case .installment:
                navigate(to: createInstallmentController())
            case .creditCard:
                navigate(to: createCreditCardPaymentController())
            case .sourceType(.atome):
                navigate(to: createAtomeController())
            case .eContextConbini, .eContextPayEasy, .eContextNetBanking:
                navigate(to: createEContextController(title: paymentMethod.localizedTitle))
            case .sourceType(.fpx):
                navigate(to: createFPXController())
            case .sourceType(.duitNowOBW):
                navigate(to: createDuitNowOBWBanksController())
            case .sourceType(.trueMoneyWallet):
                navigate(to: createTrueMoneyWalletController())
            default: break
            }
        } else if let sourceType = paymentMethod.sourceType {
            processPayment(.sourceType(sourceType), completion: completion)
        } else {
            completion()
            assertionFailure("Unexpected case for selected payment method: \(paymentMethod)")
        }
    }

    func didCancelPayment() {
        choosePaymentMethodDelegate?.choosePaymentMethodDidCancel()
    }
}

extension ChoosePaymentCoordinator: SelectSourceTypeDelegate {
    func didSelectSourceType(_ sourceType: SourceType, completion: @escaping () -> Void) {
        if sourceType.isInstallment {
            navigate(to: createInstallmentTermsController(sourceType: sourceType))
        } else {
            processPayment(.sourceType(sourceType), completion: completion)
        }
    }
}

extension ChoosePaymentCoordinator: SelectSourcePaymentDelegate {
    func didSelectSourcePayment(_ payment: Source.Payment, completion: @escaping () -> Void) {
        processPayment(payment, completion: completion)
    }
}
