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
}

extension PaymentChooserOption {
    // swiftlint:disable:next function_body_length
    fileprivate static func paymentOptions(for sourceType: SourceTypeValue) -> [PaymentChooserOption] {
        switch sourceType {
        case .trueMoney:
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
        case .mobileBankingOCBC:
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
    var allowedPaymentMethods: [SourceTypeValue] = [] {
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
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.internetBankingSource })
            controller.flowSession = self.flowSession
        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.mobileBankingSource })
            controller.flowSession = self.flowSession
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.installmentBrand })
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
            controller.showingValues = capability?[.fpx]?.banks ?? []
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
            payment = .alipay
        case .alipayCN:
            payment = .alipayCN
        case .alipayHK:
            payment = .alipayHK
        case .dana:
            payment = .dana
        case .gcash:
            payment = .gcash
        case .kakaoPay:
            payment = .kakaoPay
        case .touchNGoAlipayPlus, .touchNGo:
            payment = .touchNGo
        case .tescoLotus:
            payment = .billPayment(.tescoLotus)
        case .promptpay:
            payment = .promptpay
        case .paynow:
            payment = .paynow
        case .citiPoints:
            payment = .points(.citiPoints)
        case .rabbitLinepay:
            payment = .rabbitLinepay
        case .ocbcDigital:
            payment = .ocbcDigital
        case .grabPay, .grabPayRms:
            payment = .grabPay
        case .boost:
            payment = .boost
        case .shopeePay:
            payment = .shopeePay
        case .shopeePayJumpApp:
            payment = .shopeePayJumpApp
        case .maybankQRPay:
            payment = .maybankQRPay
        case .duitNowQR:
            payment = .duitNowQR
        case .payPay:
            payment = .payPay
        case .atome:
            goToAtome()
            return
        case .truemoneyJumpApp:
            payment = .truemoneyJumpApp
        case .weChat:
            payment = .weChat
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

    // swiftlint:disable:next function_body_length
    override func staticIndexPath(forValue value: PaymentChooserOption) -> IndexPath {
        switch value {
        case .creditCard:
            return IndexPath(row: 0, section: 0)
        case .installment:
            return IndexPath(row: 1, section: 0)
        case .truemoney:
            return IndexPath(row: 2, section: 0)
        case .promptpay:
            return IndexPath(row: 3, section: 0)
        case .citiPoints:
            return IndexPath(row: 4, section: 0)
        case .alipay:
            return IndexPath(row: 5, section: 0)
        case .internetBanking:
            return IndexPath(row: 6, section: 0)
        case .tescoLotus:
            return IndexPath(row: 7, section: 0)
        case .paynow:
            return IndexPath(row: 8, section: 0)
        case .conbini:
            return IndexPath(row: 9, section: 0)
        case .payEasy:
            return IndexPath(row: 10, section: 0)
        case .netBanking:
            return IndexPath(row: 11, section: 0)
        case .mobileBanking:
            return IndexPath(row: 12, section: 0)
        case .fpx:
            return IndexPath(row: 13, section: 0)
        case .alipayCN:
            return IndexPath(row: 14, section: 0)
        case .alipayHK:
            return IndexPath(row: 15, section: 0)
        case .dana:
            return IndexPath(row: 16, section: 0)
        case .gcash:
            return IndexPath(row: 17, section: 0)
        case .kakaoPay:
            return IndexPath(row: 18, section: 0)
        case .touchNGoAlipayPlus:
            return IndexPath(row: 19, section: 0)
        case .rabbitLinepay:
            return IndexPath(row: 20, section: 0)
        case .ocbcDigital:
            return IndexPath(row: 21, section: 0)
        case .grabPay:
            return IndexPath(row: 22, section: 0)
        case .boost:
            return IndexPath(row: 23, section: 0)
        case .shopeePay, .shopeePayJumpApp:
            return IndexPath(row: 24, section: 0)
        case .maybankQRPay:
            return IndexPath(row: 25, section: 0)
        case .duitNowQR:
            return IndexPath(row: 26, section: 0)
        case .duitNowOBW:
            return IndexPath(row: 27, section: 0)
        case .touchNGo:
            return IndexPath(row: 28, section: 0)
        case .grabPayRms:
            return IndexPath(row: 29, section: 0)
        case .atome:
            return IndexPath(row: 30, section: 0)
        case .payPay:
            return IndexPath(row: 31, section: 0)
        case .truemoneyJumpApp:
            return IndexPath(row: 32, section: 0)
        case .weChat:
            return IndexPath(row: 33, section: 0)
        }
    }

    // swiftlint:disable:next function_body_length
    func applyPaymentMethods(from capability: Capability) {
        self.capability = capability
        showsCreditCardPayment = capability.creditCardBackend != nil

        // swiftlint:disable:next closure_body_length
        allowedPaymentMethods = capability.supportedBackends.compactMap {
            switch $0.payment {
            case .alipay:
                return SourceTypeValue.alipay
            case .alipayCN:
                return SourceTypeValue.alipayCN
            case .alipayHK:
                return SourceTypeValue.alipayHK
            case .atome:
                return SourceTypeValue.atome
            case .dana:
                return SourceTypeValue.dana
            case .gcash:
                return SourceTypeValue.gcash
            case .kakaoPay:
                return SourceTypeValue.kakaoPay
            case .touchNGoAlipayPlus:
                return SourceTypeValue.touchNGoAlipayPlus
            case .touchNGo:
                return SourceTypeValue.touchNGo
            case .promptpay:
                return SourceTypeValue.promptPay
            case .paynow:
                return SourceTypeValue.payNow
            case .truemoney:
                return SourceTypeValue.trueMoney
            case .truemoneyJumpApp:
                return SourceTypeValue.trueMoneyJumpApp
            case .points(let points):
                return SourceTypeValue(points.type)
            case .installment(let brand, availableNumberOfTerms: _):
                return SourceTypeValue(brand.type)
            case .internetBanking(let bank):
                return SourceTypeValue(bank.type)
            case .billPayment(let billPayment):
                return SourceTypeValue(billPayment.type)
            case .eContext:
                return SourceTypeValue.eContext
            case .mobileBanking(let bank):
                return SourceTypeValue(bank.type)
            case .fpx:
                return SourceTypeValue.fpx
            case .rabbitLinepay:
                return SourceTypeValue.rabbitLinepay
            case .ocbcDigital:
                return SourceTypeValue.mobileBankingOCBC
            case .grabPay:
                return SourceTypeValue.grabPay
            case .grabPayRms:
                return SourceTypeValue.grabPayRms
            case .boost:
                return SourceTypeValue.boost
            case .shopeePay:
                return SourceTypeValue.shopeePay
            case .shopeePayJumpApp:
                return SourceTypeValue.shopeePayJumpApp
            case .maybankQRPay:
                return SourceTypeValue.maybankQRPay
            case .duitNowQR:
                return SourceTypeValue.duitNowQR
            case .duitNowOBW:
                return SourceTypeValue.duitNowOBW
            case .payPay:
                return SourceTypeValue.payPay
            case .weChat:
                return SourceTypeValue.weChat
            case .card, .unknownSource:
                return nil
            }
        }

        updateShowingValues()
    }

    private func loadCapabilityData() {
        flowSession?.client?.capabilityDataWithCompletionHandler { (result) in
            switch result {
            case .success(let capability):
                self.applyPaymentMethods(from: capability)
            case .failure:
                break
            }
        }
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
    func paymentOptions(from sourceTypes: [SourceTypeValue]) -> [PaymentChooserOption] {
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
