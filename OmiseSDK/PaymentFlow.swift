import UIKit

class PaymentFlow: ViewAttachable {
    let client: Client
    let amount: Int64
    let currency: String

    enum ResultState {
        case cancelled
        case selectedPaymentMethod(PaymentMethod)
    }
    
//    private weak var choosePaymentMethodDelegate: ChoosePaymentMethodDelegate?

    init(client: Client, amount: Int64, currency: String) {
        self.client = client
        self.amount = amount
        self.currency = currency
    }
    /// Creates RootViewController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - allowedPaymentMethods: List of Payment Methods to be presented in the list if `usePaymentMethodsFromCapability` is `false`
    ///   - allowedCardPayment: Shows credit card payment option if `true` and `usePaymentMethodsFromCapability` is `false`
    ///   - usePaymentMethodsFromCapability: If `true`then it loads list of Payment Methods from Capability API and ignores previous parameters
    func createChoosePaymentMethodController(
        allowedPaymentMethods: [SourceType] = [],
        allowedCardPayment: Bool = true,
        usePaymentMethodsFromCapability: Bool,
        delegate: ChoosePaymentMethodDelegate
    ) -> TableListController {
        // Setup ViewController
        let listController = TableListController()
        if #available(iOSApplicationExtension 11.0, *) {
            listController.navigationItem.largeTitleDisplayMode = .always
        }
        listController.navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
        listController.navigationItem.backBarButtonItem = .empty
        listController.navigationItem.rightBarButtonItem = ClosureBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain) { [weak delegate] _ in
                delegate?.choosePaymentMethodDidCancel()
        }

        // Setup ViewModel
        let viewModel = ChoosePaymentMethodViewModel()
        if usePaymentMethodsFromCapability {
            viewModel.setupCapabilityPaymentMethods(client: client)
        } else {
            viewModel.setupAllowedPaymentMethods(
                allowedPaymentMethods,
                allowedCardPayment: allowedCardPayment,
                client: client
            )
        }
        viewModel.reloadPaymentMethods()

        // Connect ViewController and ViewModel
        viewModel.onPaymentMethodsUpdated = { [weak listController] viewContexts in
            listController?.items = viewContexts
        }

        listController.didSelectCellHandler = { [weak viewModel, weak listController, weak delegate] cell, indexPath in
            guard let delegate = delegate,
                    let viewModel = viewModel,
                    let listController = listController else {
                return
            }

            if viewModel.showsActivityForSelectedPaymentMethod(at: indexPath.row) {
                cell.startAccessoryActivityIndicator()
                listController.lockUserInferface()
            }

            if let paymentMethod = viewModel.paymentMethod(at: indexPath.row) {
                self.didSelectPaymentMethod(
                    paymentMethod,
                    listController: listController,
                    delegate: delegate
                )
            }
        }

        // Finalize setup
        listController.attach(viewModel)
        listController.attach(self)
        return listController
    }

    func createDuitNowController(title: String) -> TableListController {
        let listController = TableListController()
        if #available(iOSApplicationExtension 11.0, *) {
            listController.navigationItem.largeTitleDisplayMode = .never
        }
        listController.navigationItem.title = title
        listController.navigationItem.backBarButtonItem = .empty

        let banks = PaymentInformation.DuitNowOBW.Bank.allCases.sorted {
            $0.localizedTitle.localizedCaseInsensitiveCompare($1.localizedTitle) == .orderedAscending
        }

        listController.items = banks.map {
            TableCellContext(
                icon: $0.listIcon,
                title: $0.localizedTitle,
                accessoryIcon: UIImage(omise: "Redirect")
            )
        }

        listController.didSelectCellHandler = { [banks, weak listController] cell, indexPath in
            guard let listController = listController else { return }

            cell.startAccessoryActivityIndicator()
            listController.lockUserInferface()

            if let bank = banks.at(indexPath.row) {
                print("Bank selected: \(bank)")
            }

//            if let paymentMethod = viewModel.paymentMethod(at: indexPath.row) {
//                self.didSelectPaymentMethod(
//                    paymentMethod,
//                    listController: listController,
//                    delegate: delegate
//                )
//            }
        }

        return listController
    }
}

extension PaymentFlow {
    func didSelectPaymentMethod(
        _ paymentMethod: PaymentMethod,
        listController: TableListController,
        delegate: ChoosePaymentMethodDelegate
    ) {
        let viewController: UIViewController?

        switch paymentMethod {
        case .creditCard:
            viewController = UIViewController()
        case .installment:
            viewController = UIViewController()
        case .internetBanking:
            viewController = UIViewController()
        case .mobileBanking:
            viewController = UIViewController()
        case .eContextConbini:
            viewController = UIViewController()
        case .eContextPayEasy:
            viewController = UIViewController()
        case .eContextNetBanking:
            viewController = UIViewController()
        case .sourceType(.atome):
            viewController = UIViewController()
        case .sourceType(.barcodeAlipay):
            viewController = UIViewController()
        case .sourceType(.duitNowOBW):
            viewController = createDuitNowController(title: paymentMethod.localizedTitle)
        case .sourceType(.fpx):
            viewController = UIViewController()
        case .sourceType(.trueMoneyWallet):
            viewController = UIViewController()
        default:
            viewController = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak listController] in
                listController?.unlockUserInterface()
            }
        }

        if let viewController = viewController {
            viewController.view.backgroundColor = .white
            viewController.title = paymentMethod.localizedTitle
            listController.navigationController?.pushViewController(
                viewController,
                animated: true
            )
        }
        print("doSomething here with payment '\(paymentMethod)'")

    }
}

// protocol NavigationFlow<Route> {
//    associatedtype Route
//    func navigate(to: Route)
// }
//
// extension PaymentFlow: NavigationFlow {
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
//        //        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
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
//        //        case (_, let controller as EContextInformationInputViewController):
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
//        //        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
//        //            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
//        //            //            capability?[.fpx]?.banks ?? []
//        //
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
//        ////            controller.showingValues = [.duitNowOBWBanks]
//        ////            [PaymentInformation.DuitNowOBW.Bank]
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
