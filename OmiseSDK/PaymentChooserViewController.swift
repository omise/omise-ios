// swiftlint:disable file_length
import UIKit
import os

enum PaymentChooserOption: CaseIterable, Equatable, CustomStringConvertible {
    case alipay
    case alipayCN
    case alipayHK
    case atome
    case boost
    case citiPoints
    case conbini
    case creditCard
    case dana
    case duitNowOBW
    case duitNowQR
    case fpx
    case gcash
    case grabPay
    case grabPayRms
    case installment
    case internetBanking
    case kakaoPay
    case maybankQRPay
    case mobileBanking
    case netBanking
    case ocbcDigital
    case payEasy
    case paynow
    case payPay
    case promptpay
    case rabbitLinepay
    case shopeePay
    case shopeePayJumpApp
    case tescoLotus
    case touchNGo
    case touchNGoAlipayPlus
    case truemoney
    case truemoneyJumpApp
    case weChat

    static var alphabetical: [PaymentChooserOption] {
        PaymentChooserOption.allCases.sorted {
            $0.description.localizedCaseInsensitiveCompare($1.description) == .orderedAscending
        }
    }

    static let topList: [PaymentChooserOption] = [
        .creditCard,
        .paynow,
        .promptpay,
        .truemoney,
        .truemoneyJumpApp,
        .mobileBanking,
        .internetBanking,
        .alipay,
        .installment,
        .ocbcDigital,
        .rabbitLinepay,
        .shopeePay,
        .shopeePayJumpApp,
        .alipayCN,
        .alipayHK
    ]

    static var sorting: [PaymentChooserOption] {
        var sorted = topList
        for item in alphabetical where !sorted.contains(item) {
            sorted.append(item)
        }
        return sorted
    }

    var description: String {
        switch self {
        case .creditCard:
            return "Credit Card"
        case .installment:
            return "Installment"
        case .internetBanking:
            return "InternetBanking"
        case .mobileBanking:
            return "MobileBanking"
        case .tescoLotus:
            return "Tesco Lotus"
        case .conbini:
            return "Conbini"
        case .payEasy:
            return "PayEasy"
        case .netBanking:
            return "NetBanking"
        case .alipay:
            return "Alipay"
        case .alipayCN:
            return "Alipay CN"
        case .alipayHK:
            return "Alipay HK"
        case .atome:
            return "Atome"
        case .dana:
            return "DANA"
        case .gcash:
            return "GCash"
        case .kakaoPay:
            return "Kakao Pay"
        case .touchNGoAlipayPlus:
            return "TNG eWallet"
        case .promptpay:
            return "PromptPay"
        case .paynow:
            return "PayNow"
        case .truemoney:
            return "TrueMoney Wallet"
        case .truemoneyJumpApp:
            return "TrueMoney"
        case .citiPoints:
            return "CitiPoints"
        case .fpx:
            return "FPX"
        case .rabbitLinepay:
            return "Rabbit LINE Pay"
        case .ocbcDigital:
            return "OCBC Digital"
        case .grabPay:
            return "Grab"
        case .boost:
            return "Boost"
        case .shopeePay:
            return "ShopeePay"
        case .shopeePayJumpApp:
            return "ShopeePay"
        case .maybankQRPay:
            return "Maybank QRPay"
        case .duitNowQR:
            return "DuitNow QR"
        case .duitNowOBW:
            return "DuitNow OBW"
        case .touchNGo:
            return "Touch 'n Go"
        case .grabPayRms:
            return "GrabPay"
        case .payPay:
            return "PayPay"
        case .weChat:
            return "WeChat Pay"
        }
    }
    var listIcon: UIImage? {
        switch self {
        case .creditCard:
            return UIImage(named: "Card", in: .omiseSDK, compatibleWith: nil)
        case .installment:
            return UIImage(named: "Installment", in: .omiseSDK, compatibleWith: nil)
        case .internetBanking:
            return UIImage(named: "Banking", in: .omiseSDK, compatibleWith: nil)
        case .mobileBanking:
            return UIImage(named: "MobileBanking", in: .omiseSDK, compatibleWith: nil)
        case .tescoLotus:
            return UIImage(named: "Tesco", in: .omiseSDK, compatibleWith: nil)
        case .conbini:
            return UIImage(named: "Conbini", in: .omiseSDK, compatibleWith: nil)
        case .payEasy:
            return UIImage(named: "Payeasy", in: .omiseSDK, compatibleWith: nil)
        case .netBanking:
            return UIImage(named: "Netbank", in: .omiseSDK, compatibleWith: nil)
        case .alipay:
            return UIImage(named: "Alipay", in: .omiseSDK, compatibleWith: nil)
        case .alipayCN:
            return UIImage(named: "AlipayCN", in: .omiseSDK, compatibleWith: nil)
        case .alipayHK:
            return UIImage(named: "AlipayHK", in: .omiseSDK, compatibleWith: nil)
        case .atome:
            return UIImage(named: "Atome", in: .omiseSDK, compatibleWith: nil)
        case .dana:
            return UIImage(named: "dana", in: .omiseSDK, compatibleWith: nil)
        case .gcash:
            return UIImage(named: "gcash", in: .omiseSDK, compatibleWith: nil)
        case .kakaoPay:
            return UIImage(named: "kakaopay", in: .omiseSDK, compatibleWith: nil)
        case .touchNGoAlipayPlus:
            return UIImage(named: "touch-n-go", in: .omiseSDK, compatibleWith: nil)
        case .promptpay:
            return UIImage(named: "PromptPay", in: .omiseSDK, compatibleWith: nil)
        case .paynow:
            return UIImage(named: "PayNow", in: .omiseSDK, compatibleWith: nil)
        case .truemoney:
            return UIImage(named: "TrueMoney", in: .omiseSDK, compatibleWith: nil)
        case .truemoneyJumpApp:
            return UIImage(named: "TrueMoney", in: .omiseSDK, compatibleWith: nil)
        case .citiPoints:
            return UIImage(named: "CitiBank", in: .omiseSDK, compatibleWith: nil)
        case .fpx:
            return UIImage(named: "FPX", in: .omiseSDK, compatibleWith: nil)
        case .rabbitLinepay:
            return UIImage(named: "RabbitLinePay", in: .omiseSDK, compatibleWith: nil)
        case .ocbcDigital:
            return UIImage(named: "ocbc-digital", in: .omiseSDK, compatibleWith: nil)
        case .grabPay:
            return UIImage(named: "Grab", in: .omiseSDK, compatibleWith: nil)
        case .boost:
            return UIImage(named: "Boost", in: .omiseSDK, compatibleWith: nil)
        case .shopeePay:
            return UIImage(named: "Shopeepay", in: .omiseSDK, compatibleWith: nil)
        case .shopeePayJumpApp:
            return UIImage(named: "Shopeepay", in: .omiseSDK, compatibleWith: nil)
        case .maybankQRPay:
            return UIImage(named: "MAE-maybank", in: .omiseSDK, compatibleWith: nil)
        case .duitNowQR:
            return UIImage(named: "DuitNow-QR", in: .omiseSDK, compatibleWith: nil)
        case .duitNowOBW:
            return UIImage(named: "Duitnow-OBW", in: .omiseSDK, compatibleWith: nil)
        case .touchNGo:
            return UIImage(named: "touch-n-go", in: .omiseSDK, compatibleWith: nil)
        case .grabPayRms:
            return UIImage(named: "Grab", in: .omiseSDK, compatibleWith: nil)
        case .payPay:
            return UIImage(named: "PayPay", in: .omiseSDK, compatibleWith: nil)
        case .weChat:
            return UIImage(named: "wechat_pay", in: .omiseSDK, compatibleWith: nil)
        }
    }
}
 
extension PaymentChooserOption {
    // swiftlint:disable:next function_body_length
    fileprivate static func paymentOptions(for sourceType: SourceType) -> [PaymentChooserOption] {
        switch sourceType {
        case .trueMoneyWallet:
            return [.truemoney]
        case .trueMoneyJumpApp:
            return [.truemoneyJumpApp]
        case .installmentFirstChoice, .installmentMBB, .installmentKBank, .installmentKTC,
                .installmentBBL, .installmentBAY, .installmentSCB, .installmentTTB, .installmentUOB:
            return [.installment]
        case .billPaymentTescoLotus:
            return [.tescoLotus]
        case .eContext:
            return [.conbini, .payEasy, .netBanking]
        case .alipay:
            return [.alipay]
        case .alipayCN:
            return [.alipayCN]
        case .alipayHK:
            return [.alipayHK]
        case .atome:
            return [.atome]
        case .dana:
            return [.dana]
        case .gcash:
            return [.gcash]
        case .kakaoPay:
            return [.kakaoPay]
        case .touchNGoAlipayPlus:
            return [.touchNGoAlipayPlus]
        case .touchNGo:
            return [.touchNGo]
        case .internetBankingBAY, .internetBankingBBL:
            return [.internetBanking]
        case .mobileBankingSCB, .mobileBankingKBank, .mobileBankingBAY, .mobileBankingBBL, .mobileBankingKTB:
            return [.mobileBanking]
        case .payNow:
            return [.paynow]
        case .promptPay:
            return [.promptpay]
        case .pointsCiti:
            return [.citiPoints]
        case .barcodeAlipay:
            return []
        case .fpx:
            return [.fpx]
        case .rabbitLinepay:
            return [.rabbitLinepay]
        case .ocbcDigital:
            return [.ocbcDigital]
        case .grabPay:
            return [.grabPay]
        case .grabPayRms:
            return [.grabPayRms]
        case .boost:
            return [.boost]
        case .shopeePay:
            return [.shopeePay]
        case .shopeePayJumpApp:
            return [.shopeePayJumpApp]
        case .maybankQRPay:
            return [.maybankQRPay]
        case .duitNowQR:
            return [.duitNowQR]
        case .duitNowOBW:
            return [.duitNowOBW]
        case .payPay:
            return [.payPay]
        case .weChat:
            return [.weChat]
        }
    }
}

// swiftlint:disable:next type_body_length
class PaymentChooserViewController: AdaptableStaticTableViewController<PaymentChooserOption>,
                                    PaymentSourceChooser,
                                    PaymentChooserUI {
    var capability: Capability?
    var flowSession: PaymentCreatorFlowSession?
    var duitNowOBWBanks: [PaymentInformation.DuitNowOBW.Bank] = PaymentInformation.DuitNowOBW.Bank.allCases

    var showsCreditCardPayment = true {
        didSet {
            updateShowingValues()
        }
    }
    var allowedPaymentMethods: [SourceType] = [] {
        didSet {
            updateShowingValues()
        }
    }

    @IBOutlet private var paymentMethodNameLables: [UILabel]!

    @IBInspectable var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }

    @IBInspectable var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyPrimaryColor()
        applySecondaryColor()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        applyNavigationBarStyle()
        updateShowingValues()
    }

    // swiftlint:disable:next function_body_length
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
            controller.publicKey = flowSession?.client?.publicKey
            controller.delegate = flowSession
            controller.navigationItem.rightBarButtonItem = nil
        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.filter({ $0.isInternetBanking })
            controller.flowSession = self.flowSession
        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.filter({ $0.isMobileBanking })
            controller.flowSession = self.flowSession
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.filter({ $0.isInstallment })
            controller.flowSession = self.flowSession
        case (_, let controller as EContextInformationInputViewController):
            controller.flowSession = self.flowSession
            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(element(forUIIndexPath:)) {
                switch element {
                case .conbini:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.convenience-store.navigation-item.title",
                        bundle: .omiseSDK,
                        value: "Konbini",
                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
                    )
                case .netBanking:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.netbanking.navigation-item.title",
                        bundle: .omiseSDK,
                        value: "Net Bank",
                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
                    )
                case .payEasy:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.pay-easy.navigation-item.title",
                        bundle: .omiseSDK,
                        value: "Pay-easy",
                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
                    )
                default: break
                }
            }
        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
            controller.flowSession = self.flowSession
        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
            //            capability?[.fpx]?.banks ?? []

            controller.flowSession = self.flowSession
        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
            controller.showingValues = duitNowOBWBanks
            controller.flowSession = self.flowSession
        default:
            break
        }

        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        cell.accessoryView?.tintColor = currentSecondaryColor
        return cell
    }

    // swiftlint:disable:next function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let payment: PaymentInformation

        let selectedType = element(forUIIndexPath: indexPath)

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
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(payment) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }

    func goToAtome() {
        let vc = AtomeFormViewController(viewModel: AtomeFormViewModel(flowSession: flowSession))
        vc.preferredPrimaryColor = self.preferredPrimaryColor
        vc.preferredSecondaryColor = self.preferredSecondaryColor

        navigationController?.pushViewController(vc, animated: true)
    }

    // TODO: Add implementation for AdaptableStaticTableViewController
    private func setupTableViewCells() {
        createTableViewCellsClosure = { [weak self] paymentOption, _, cell, _ in
            guard let self = self else { return }
            cell.textLabel?.text = paymentOption.description
            cell.imageView?.image = paymentOption.listIcon
            cell.accessoryView = UIImageView(image: UIImage(named: "Next"))

            if let cell = cell as? PaymentOptionTableViewCell {
                cell.separatorView.backgroundColor = self.currentSecondaryColor
            }
            cell.accessoryView?.tintColor = self.currentSecondaryColor
        }
    }

    func applyPaymentMethods(from capability: Capability) {
        self.capability = capability
        showsCreditCardPayment = capability.cardPaymentMethod != nil

        allowedPaymentMethods = capability.paymentMethods.compactMap {
            SourceType(rawValue: $0.name)
        }

        updateShowingValues()
    }

    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

        paymentMethodNameLables.forEach {
            $0.textColor = currentPrimaryColor
        }
    }

    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }

    private func updateShowingValues() {
        var paymentMethodsToShow = paymentOptions(from: allowedPaymentMethods)
        paymentMethodsToShow = appendCreditCardPayment(paymentOptions: paymentMethodsToShow)
        paymentMethodsToShow = filterTrueMoney(paymentOptions: paymentMethodsToShow)
        paymentMethodsToShow = filterShopeePay(paymentOptions: paymentMethodsToShow)
        showingValues = paymentMethodsToShow.reorder(by: PaymentChooserOption.sorting)

        os_log("Payment Chooser: Showing options - %{private}@",
               log: uiLogObject,
               type: .info,
               showingValues.map { $0.description }.joined(separator: ", "))
    }

    @IBAction private func requestToClose(_ sender: Any) {
        flowSession?.requestToCancel()
    }
}

private extension PaymentChooserViewController {
    func paymentOptions(from sourceTypes: [SourceType]) -> [PaymentChooserOption] {
        let paymentOptions: [PaymentChooserOption] = sourceTypes.reduce(into: []) { (result, sourceType) in
            let paymentOptions = PaymentChooserOption.paymentOptions(for: sourceType)
            for paymentOption in paymentOptions where !result.contains(paymentOption) {
                result.append(paymentOption)
            }
        }
        return paymentOptions
    }

    func appendCreditCardPayment(paymentOptions: [PaymentChooserOption]) -> [PaymentChooserOption] {
        var filter = paymentOptions
        if showsCreditCardPayment {
            filter.insert(.creditCard, at: 0)
        }
        return filter
    }

    func filterTrueMoney(paymentOptions: [PaymentChooserOption]) -> [PaymentChooserOption] {
        var filter = paymentOptions
        if filter.contains(.truemoney) && filter.contains(.truemoneyJumpApp) {
            filter.removeAll { $0 == .truemoney }
        }
        return filter
    }

    func filterShopeePay(paymentOptions: [PaymentChooserOption]) -> [PaymentChooserOption] {
        var filter = paymentOptions
        if filter.contains(.shopeePay) && filter.contains(.shopeePayJumpApp) {
            filter.removeAll { $0 == .shopeePay }
        }
        return filter
    }
}
