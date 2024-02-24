import UIKit

class ChoosePaymentCoordinator: ViewAttachable {
    let client: Client
    let amount: Int64
    let currency: String
    let currentCountry: Country?

    enum ResultState {
        case cancelled
        case selectedPaymentMethod(PaymentMethod)
    }
    
    weak var choosePaymentMethodDelegate: ChoosePaymentMethodDelegate?

    weak var rootViewController: UIViewController?

    init(client: Client, amount: Int64, currency: String, currentCountry: Country?) {
        self.client = client
        self.amount = amount
        self.currency = currency
        self.currentCountry = currentCountry
    }

    /// Creates SelectPaymentController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - allowedPaymentMethods: List of Payment Methods to be presented in the list if `usePaymentMethodsFromCapability` is `false`
    ///   - allowedCardPayment: Shows credit card payment option if `true` and `usePaymentMethodsFromCapability` is `false`
    ///   - usePaymentMethodsFromCapability: If `true`then it loads list of Payment Methods from Capability API and ignores previous parameters
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

    /// Creates Credit Carc Payment screen and attach current flow object inside created controller to be deallocated together
    func createCreditCardPaymentController() -> CreditCardPaymentController {
        let viewModel = CreditCardPaymentViewModel(currentCountry: currentCountry, delegate: self)
        let viewController = CreditCardPaymentController(nibName: nil, bundle: .omiseSDK)
        viewController.viewModel = viewModel
        viewController.title = PaymentMethod.creditCard.localizedTitle
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

extension ChoosePaymentCoordinator {
    func navigate(to viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    func processPayment(_ card: CreateTokenPayload.Card, completion: @escaping () -> Void) {
        guard let delegate = choosePaymentMethodDelegate else { return }
        let tokenPayload = CreateTokenPayload(card: card)

        client.createToken(payload: tokenPayload) { [weak delegate] result in
            switch result {
            case .success(let token):
                delegate?.choosePaymentMethodDidComplete(with: token)
            case .failure(let error):
                delegate?.choosePaymentMethodDidComplete(with: error)
            }
            completion()
        }
    }

    func processPayment(_ payment: Source.Payment, completion: @escaping () -> Void) {
        guard let delegate = choosePaymentMethodDelegate else { return }
        let sourcePayload = CreateSourcePayload(
            amount: amount,
            currency: currency,
            details: payment
        )

        client.createSource(payload: sourcePayload) { [weak delegate] result in
            switch result {
            case .success(let source):
                delegate?.choosePaymentMethodDidComplete(with: source)
            case .failure(let error):
                delegate?.choosePaymentMethodDidComplete(with: error)
            }
            completion()
        }
    }
}

// protocol NavigationFlow<Route> {
//    associatedtype Route
//    func navigate(to: Route)
// }
//
// extension ChoosePaymentCoordinator: NavigationFlow {
//    enum Route {
//        case creditCard
//        case installments
//        case mobileBanking
//        case internetBanking
//        case atome
//        case trueMoneyWallet
//        case duitNowOBW
//        case eContext
//        case fpx
//    }
//
//    func navigate(to: Route) {
//        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //        switch (segue.identifier, segue.destination) {
//        //        case ("GoToCreditCardPaymentSegue"?, let controller as CreditCardPaymentController):
//        //            controller.publicKey = viewModel.flowSession?.client?.publicKey
//        //            controller.delegate = viewModel.flowSession
//        //            controller.navigationItem.rightBarButtonItem = nil
//        //        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
//        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInternetBanking })
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
//        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isMobileBanking })
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
//        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInstallment })
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case (_, let controller as EContextPaymentFormController):
//        //            controller.flowSession = self.viewModel.flowSession
//        //            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(item(at:)) {
//        //                switch element {
//        //                case .conbini:
//        //                    controller.navigationItem.title = NSLocalizedString(
//        //                        "econtext.convenience-store.navigation-item.title",
//        //                        bundle: .omiseSDK,
//        //                        value: "Konbini",
//        //                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
//        //                    )
//        //                case .netBanking:
//        //                    controller.navigationItem.title = NSLocalizedString(
//        //                        "econtext.netbanking.navigation-item.title",
//        //                        bundle: .omiseSDK,
//        //                        value: "Net Bank",
//        //                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
//        //                    )
//        //                case .payEasy:
//        //                    controller.navigationItem.title = NSLocalizedString(
//        //                        "econtext.pay-easy.navigation-item.title",
//        //                        bundle: .omiseSDK,
//        //                        value: "Pay-easy",
//        //                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
//        //                    )
//        //                default: break
//        //                }
//        //            }
//        //        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyPaymentFormController):
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToFPXFormSegue"?, let controller as FPXPaymentFormController):
//        //            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
//        //            //            capability?[.fpx]?.banks ?? []
//        //
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
//        ////            controller.showingValues = [.duitNowOBWBanks]
//        ////            [Payment.DuitNowOBW.Bank]
//        //            controller.flowSession = self.viewModel.flowSession
//        //        default:
//        //            break
//        //        }
//        //
//        //        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
//        //            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
//        //            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
//        //        }
//        //    }
//    }
//
//    private func viewController(for route: Route) -> UIViewController {
//        switch self {
//        default:
//            return UIViewController()
//        }
//    }
// }
