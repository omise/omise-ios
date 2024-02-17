// swiftlint:disable file_length
import UIKit
import os

protocol PaymentChooserControllerViewModel {
    var viewContext: [PaymentChooserController.ViewContext] { get }
    var onViewContextChanged: ([PaymentChooserController.ViewContext]) -> Void { get }
}

protocol PaymentChooserControllerDelegate {
}

/// swiftlint:disable:next type_body_length
class PaymentChooserController: UITableViewController {

    struct ViewContext: Equatable {
        let icon: UIImage?
        let title: String
        let accessoryIcon: UIImage?
    }

    let viewModel = ViewModel()

    func reloadIfLoaded() {
        if isViewLoaded {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        applyNavigationBarStyle()
        tableView.rowHeight = 64
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfViewContexts
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let viewContext = viewModel.viewContext(at: indexPath.row)

        cell.textLabel?.text = viewContext?.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
        cell.textLabel?.textColor = UIStyle.Color.primary.uiColor

        cell.imageView?.image = viewContext?.icon
        cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)

        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = UIStyle.Color.secondary.uiColor
        }
        cell.accessoryView?.tintColor = UIStyle.Color.secondary.uiColor

        return cell
    }

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

    // swiftlint:disable:next function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

//        let option = item(at: indexPath)
//        switch option {
//        case .c
//
//        }
//        let element: ViewContext = self.item(at: indexPath)
//        let selectedType = SourceType(rawValue: element.name)
/*
        os_log("Payment Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedType.description)
        switch selectedType {
        case .alipay:
            payment = .sourceType(.alipay)
        case .alipayCN:
            payment = .sourceType(.alipayCN)
        case .alipayHK:
            payment = .sourceType(.alipayHK)
        case .dana:
            payment = .sourceType(.dana)
        case .gcash:
            payment = .sourceType(.gcash)
        case .kakaoPay:
            payment = .sourceType(.kakaoPay)
        case .touchNGoAlipayPlus, .touchNGo:
            payment = .sourceType(.touchNGo)
        case .tescoLotus:
            payment = .sourceType(.billPaymentTescoLotus)
        case .promptpay:
            payment = .sourceType(.promptPay)
        case .paynow:
            payment = .sourceType(.payNow)
        case .citiPoints:
            payment = .sourceType(.pointsCiti)
        case .rabbitLinepay:
            payment = .sourceType(.rabbitLinepay)
        case .ocbcDigital:
            payment = .sourceType(.ocbcDigital)
        case .grabPay, .grabPayRms:
            payment = .sourceType(.grabPay)
        case .boost:
            payment = .sourceType(.boost)
        case .shopeePay:
            payment = .sourceType(.shopeePay)
        case .shopeePayJumpApp:
            payment = .sourceType(.shopeePayJumpApp)
        case .maybankQRPay:
            payment = .sourceType(.maybankQRPay)
        case .duitNowQR:
            payment = .sourceType(.duitNowQR)
        case .payPay:
            payment = .sourceType(.payPay)
        case .atome:
            goToAtome()
            return
        case .truemoneyJumpApp:
            payment = .sourceType(.trueMoneyJumpApp)
        case .weChat:
            payment = .sourceType(.weChat)
        default:
            return
        }

        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = UIStyle.Color.secondary.uiColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(payment) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
 */
    }

    /*
    func goToAtome() {
        let vc = AtomeFormViewController(viewModel: AtomeFormViewModel(flowSession: flowSession))
        vc.preferredPrimaryColor = self.preferredPrimaryColor
        vc.preferredSecondaryColor = self.preferredSecondaryColor

        navigationController?.pushViewController(vc, animated: true)
    }
     */

    @IBAction private func closeTapped(_ sender: Any) {
        viewModel.flowSession?.requestToCancel()
    }
}
