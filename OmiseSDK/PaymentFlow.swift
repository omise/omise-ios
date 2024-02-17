import UIKit

public typealias PaymentResultClosure = (PaymentResult) -> Void
public enum PaymentResult {
    case token(Token)
    case source(Source)
    case error(Error)
    case cancel
}

public class PaymentFlow {
    var completion: PaymentResultClosure = { _ in }
    let client: Client
    let amount: Int64
    let currency: String

    init(client: Client, amount: Int64, currency: String) {
        self.client = client
        self.amount = amount
        self.currency = currency
    }
    /// Creates RootViewController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - allowedPaymentMethods: List of Payment Methods to be presented in the list
    ///   - usePaymentMethodsFromCapability: If true then take payment methods from client.capability()
    func createRootViewController(
        allowedPaymentMethods: [SourceType],
        usePaymentMethodsFromCapability: Bool,
        completion: @escaping PaymentResultClosure
    ) -> ChoosePaymentMethodController {
        let rootViewController = ChoosePaymentMethodController()
        rootViewController.addChild(PaymentFlowContainerController(self))
        let viewModel = rootViewController.viewModel
        viewModel.allowedPaymentMethods = allowedPaymentMethods
        viewModel.paymentAmount = amount
        viewModel.paymentCurrency = currency
        viewModel.completion = completion
        viewModel.client = client
        viewModel.usePaymentMethodsFromCapability = usePaymentMethodsFromCapability
        return rootViewController
    }
}

protocol NavigationFlow<Route> {
    associatedtype Route
    func navigate(to: Route)
}

extension PaymentFlow: NavigationFlow {
    enum Route {
        case creditCard
        case installments
        case mobileBanking
        case internetBanking
        case atome
        case trueMoneyWaller
        case duitNowOBW
        case eContext
        case fpx
    }

    func navigate(to: Route) {
        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        switch (segue.identifier, segue.destination) {
        //        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
        //            controller.publicKey = viewModel.flowSession?.client?.publicKey
        //            controller.delegate = viewModel.flowSession
        //            controller.navigationItem.rightBarButtonItem = nil
        //        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInternetBanking })
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isMobileBanking })
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInstallment })
        //            controller.flowSession = self.viewModel.flowSession
        //        case (_, let controller as EContextInformationInputViewController):
        //            controller.flowSession = self.viewModel.flowSession
        //            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(item(at:)) {
        //                switch element {
        //                case .conbini:
        //                    controller.navigationItem.title = NSLocalizedString(
        //                        "econtext.convenience-store.navigation-item.title",
        //                        bundle: .omiseSDK,
        //                        value: "Konbini",
        //                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
        //                    )
        //                case .netBanking:
        //                    controller.navigationItem.title = NSLocalizedString(
        //                        "econtext.netbanking.navigation-item.title",
        //                        bundle: .omiseSDK,
        //                        value: "Net Bank",
        //                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
        //                    )
        //                case .payEasy:
        //                    controller.navigationItem.title = NSLocalizedString(
        //                        "econtext.pay-easy.navigation-item.title",
        //                        bundle: .omiseSDK,
        //                        value: "Pay-easy",
        //                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
        //                    )
        //                default: break
        //                }
        //            }
        //        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
        //            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
        //            //            capability?[.fpx]?.banks ?? []
        //
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
        ////            controller.showingValues = [.duitNowOBWBanks]
        ////            [PaymentInformation.DuitNowOBW.Bank]
        //            controller.flowSession = self.viewModel.flowSession
        //        default:
        //            break
        //        }
        //
        //        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
        //            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
        //            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
        //        }
        //    }
    }

    private func viewController(for route: Route) -> UIViewController {
        switch self {
        default:
            return UIViewController()
        }
    }
}

/// This class is used to store PaymentFlow and attach PaymentFlowContainerController to rootViewController
/// It will be deallocated as soon as rootViewController is dismissed
class PaymentFlowContainerController: UIViewController {
    var paymentFlow: PaymentFlow?
    init(_ paymentFlow: PaymentFlow) {
        self.paymentFlow = paymentFlow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
