// swiftlint:disable file_length

import UIKit
import OmiseSDK

class PaymentSettingTableViewController: UITableViewController {

    let amountFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        return numberFormatter
    }()

    var currentAmount: Int64 = 0
    var currentCurrency: Currency = .thb {
        willSet {
            guard isViewLoaded else {
                return
            }
            cell(for: currentCurrency)?.accessoryType = .none
        }
        didSet {
            let numberOfDigits = Int(log10(Double(currentCurrency.factor)))
            amountFormatter.minimumFractionDigits = numberOfDigits
            amountFormatter.maximumFractionDigits = numberOfDigits

            guard isViewLoaded else {
                return
            }
            cell(for: currentCurrency)?.accessoryType = .checkmark
            amountField.text = amountFormatter.string(from: NSNumber(value: currentCurrency.convert(fromSubunit: currentAmount)))
        }
    }

    var currentCurrencyCode: String {
        get {
            return currentCurrency.code
        }
        set {
            currentCurrency = Currency(code: newValue)
        }
    }

    var usesCapabilityDataForPaymentMethods = true {
        didSet {
            guard isViewLoaded else {
                return
            }

            useCapabilityAPIValuesCell.accessoryType = usesCapabilityDataForPaymentMethods ? .checkmark : .none
            useSpecifiedValuesCell.accessoryType = usesCapabilityDataForPaymentMethods ? .none : .checkmark
        }
    }

    var allowedPaymentMethods: Set<SourceTypeValue> = [] {
        willSet {
            guard isViewLoaded else {
                return
            }
            let removingPaymentMethods = allowedPaymentMethods.subtracting(newValue)
            removingPaymentMethods.compactMap(self.cell(for:)).forEach {
                $0.accessoryType = .none
            }
        }
        didSet {
            guard isViewLoaded else {
                return
            }
            let addingPaymentMethods = allowedPaymentMethods.subtracting(oldValue)
            addingPaymentMethods.compactMap(self.cell(for:)).forEach {
                $0.accessoryType = .checkmark
            }
        }
    }

    @IBOutlet private var amountField: UITextField!
    @IBOutlet private var amountFieldInputAccessoryView: UIToolbar!

    @IBOutlet private var thbCurrencyCell: UITableViewCell!
    @IBOutlet private var jpyCurrencyCell: UITableViewCell!
    @IBOutlet private var usdCurrencyCell: UITableViewCell!
    @IBOutlet private var sgdCurrencyCell: UITableViewCell!
    @IBOutlet private var myrCurrencyCell: UITableViewCell!

    @IBOutlet private var internetBankingBAYPaymentCell: UITableViewCell!
    @IBOutlet private var internetBankingBBLPaymentCell: UITableViewCell!
    @IBOutlet private var alipayPaymentCell: UITableViewCell!
    @IBOutlet private var alipayCNPaymentCell: UITableViewCell!
    @IBOutlet private var alipayHKPaymentCell: UITableViewCell!
    @IBOutlet private var atomePaymentCell: UITableViewCell!
    @IBOutlet private var payPayPaymentCell: UITableViewCell!
    @IBOutlet private var danaPaymentCell: UITableViewCell!
    @IBOutlet private var gcashPaymentCell: UITableViewCell!
    @IBOutlet private var kakaoPayPaymentCell: UITableViewCell!
    @IBOutlet private var touchNGoPaymentCell: UITableViewCell!
    @IBOutlet private var billPaymentTescoLotusPaymentCell: UITableViewCell!
    @IBOutlet private var installmentBAYPaymentCell: UITableViewCell!
    @IBOutlet private var installmentFirstChoicePaymentCell: UITableViewCell!
    @IBOutlet private var installmentBBLPaymentCell: UITableViewCell!
    @IBOutlet private var installmentMBBPaymentCell: UITableViewCell!
    @IBOutlet private var installmentKTCPaymentCell: UITableViewCell!
    @IBOutlet private var installmentKBankPaymentCell: UITableViewCell!
    @IBOutlet private var installmentSCBPaymentCell: UITableViewCell!
    @IBOutlet private var installmentCitiPaymentCell: UITableViewCell!
    @IBOutlet private var installmentTTBPaymentCell: UITableViewCell!
    @IBOutlet private var installmentUOBPaymentCell: UITableViewCell!
    @IBOutlet private var mobileBankingSCBPaymentCell: UITableViewCell!
    @IBOutlet private var mobileBankingKBankPaymentCell: UITableViewCell!
    @IBOutlet private var mobileBankingBBLPaymentCell: UITableViewCell!
    @IBOutlet private var mobileBankingBAYPaymentCell: UITableViewCell!
    @IBOutlet private var mobileBankingKTBPaymentCell: UITableViewCell!
    @IBOutlet private var eContextPaymentCell: UITableViewCell!
    @IBOutlet private var promptpayPaymentCell: UITableViewCell!
    @IBOutlet private var paynowPaymentCell: UITableViewCell!
    @IBOutlet private var truemoneyPaymentCell: UITableViewCell!
    @IBOutlet private var truemoneyJumpAppPaymentCell: UITableViewCell!
    @IBOutlet private var pointsCitiCell: UITableViewCell!
    @IBOutlet private var fpxCell: UITableViewCell!
    @IBOutlet private var rabbitLinepayCell: UITableViewCell!
    @IBOutlet private var OCBCPAOPaymentCell: UITableViewCell!
    @IBOutlet private var OCBCDigitalPaymentCell: UITableViewCell!
    @IBOutlet private var grabPayPaymentCell: UITableViewCell!
    @IBOutlet private var boostPaymentCell: UITableViewCell!
    @IBOutlet private var shopeePayPaymentCell: UITableViewCell!
    @IBOutlet private var maybankQRPayPaymentCell: UITableViewCell!
    @IBOutlet private var duitNowQRPaymentCell: UITableViewCell!
    @IBOutlet private var duitNowOBWPaymentCell: UITableViewCell!
    @IBOutlet private var useCapabilityAPIValuesCell: UITableViewCell!
    @IBOutlet private var useSpecifiedValuesCell: UITableViewCell!
    @IBOutlet private var weChatPaymentCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        cell(for: currentCurrency)?.accessoryType = .checkmark
        allowedPaymentMethods.compactMap(self.cell(for:)).forEach {
            $0.accessoryType = .checkmark
        }

        amountField.text = amountFormatter.string(from: NSNumber(value: currentCurrency.convert(fromSubunit: currentAmount)))
        amountField.inputAccessoryView = amountFieldInputAccessoryView

        useCapabilityAPIValuesCell.accessoryType = usesCapabilityDataForPaymentMethods ? .checkmark : .none
        useSpecifiedValuesCell.accessoryType = usesCapabilityDataForPaymentMethods ? .none : .checkmark
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            amountField.becomeFirstResponder()
        case 1:
            guard let cell = tableView.cellForRow(at: indexPath),
                let currency = currency(for: cell) else {
                    assertionFailure("Invalid cell configuration in the Setting scene")
                    return
            }

            currentCurrency = currency
        case 2:
            switch tableView.cellForRow(at: indexPath) {
            case useCapabilityAPIValuesCell:
                usesCapabilityDataForPaymentMethods = true
            case useSpecifiedValuesCell:
                usesCapabilityDataForPaymentMethods = false
            default: break
            }
        case 3:
            guard let cell = tableView.cellForRow(at: indexPath),
                let sourceType = paymentSource(for: cell) else {
                    assertionFailure("Invalid cell configuration in the Setting scene")
                    return
            }
            if allowedPaymentMethods.contains(sourceType) {
                allowedPaymentMethods.remove(sourceType)
            } else {
                allowedPaymentMethods.insert(sourceType)
            }
        default:
            break
        }
    }
    @IBAction private func finishEditingAmount(_ sender: Any) {
        amountField.resignFirstResponder()
    }

    @IBAction private func showPresetChooser(_ sender: Any) {
        let presetChooserAlertController = UIAlertController(title: "Preset", message: nil, preferredStyle: .actionSheet)
        presetChooserAlertController.addAction(UIAlertAction(title: "Thailand", style: .default) { (_) in
            self.currentAmount = PaymentPreset.thailandPreset.paymentAmount
            self.currentCurrency = PaymentPreset.thailandPreset.paymentCurrency
            self.allowedPaymentMethods = Set(PaymentPreset.thailandPreset.allowedPaymentMethods)
        })
        presetChooserAlertController.addAction(UIAlertAction(title: "Japan", style: .default) { (_) in
            self.currentAmount = PaymentPreset.japanPreset.paymentAmount
            self.currentCurrency = PaymentPreset.japanPreset.paymentCurrency
            self.allowedPaymentMethods = Set(PaymentPreset.japanPreset.allowedPaymentMethods)
        })
        presetChooserAlertController.addAction(UIAlertAction(title: "Singapore", style: .default) { (_) in
            self.currentAmount = PaymentPreset.singaporePreset.paymentAmount
            self.currentCurrency = PaymentPreset.singaporePreset.paymentCurrency
            self.allowedPaymentMethods = Set(PaymentPreset.singaporePreset.allowedPaymentMethods)
        })
        presetChooserAlertController.addAction(UIAlertAction(title: "Malaysia", style: .default) { (_) in
            self.currentAmount = PaymentPreset.malaysiaPreset.paymentAmount
            self.currentCurrency = PaymentPreset.malaysiaPreset.paymentCurrency
            self.allowedPaymentMethods = Set(PaymentPreset.malaysiaPreset.allowedPaymentMethods)
        })

        presetChooserAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(presetChooserAlertController, animated: true, completion: nil)
    }
}

extension PaymentSettingTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.allSatisfy { (character) -> Bool in
            return "0"..."9" ~= character || (currentCurrency.factor > 1 && "." == character)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let amount = textField.text.flatMap(Double.init) else {
            return
        }
        currentAmount = currentCurrency.convert(toSubunit: amount)
        textField.text = amountFormatter.string(from: NSNumber(value: amount))
    }
}

extension PaymentSettingTableViewController {
    func currency(for cell: UITableViewCell) -> Currency? {
        switch cell {
        case thbCurrencyCell:
            return .thb
        case jpyCurrencyCell:
            return .jpy
        case usdCurrencyCell:
            return .usd
        case sgdCurrencyCell:
            return .sgd
        case myrCurrencyCell:
            return .myr
        default:
            return nil
        }
    }

    func cell(for currency: Currency) -> UITableViewCell? {
        switch currency {
        case .thb:
            return thbCurrencyCell
        case .jpy:
            return jpyCurrencyCell
        case .usd:
            return usdCurrencyCell
        case .sgd:
            return sgdCurrencyCell
        case .myr:
            return myrCurrencyCell
        default: return nil
        }
    }

    // swiftlint:disable:next function_body_length
    func paymentSource(for cell: UITableViewCell) -> SourceTypeValue? {
        switch cell {
        case internetBankingBAYPaymentCell:
            return .internetBankingBAY
        case internetBankingBBLPaymentCell:
            return .internetBankingBBL
        case alipayPaymentCell:
            return .alipay
        case alipayCNPaymentCell:
            return .alipayCN
        case alipayHKPaymentCell:
            return .alipayHK
        case atomePaymentCell:
            return .atome
        case danaPaymentCell:
            return .dana
        case gcashPaymentCell:
            return .gcash
        case kakaoPayPaymentCell:
            return .kakaoPay
        case touchNGoPaymentCell:
            return .touchNGo
        case billPaymentTescoLotusPaymentCell:
            return .billPaymentTescoLotus
        case installmentBAYPaymentCell:
            return .installmentBAY
        case installmentFirstChoicePaymentCell:
            return .installmentFirstChoice
        case installmentBBLPaymentCell:
            return .installmentBBL
        case installmentMBBPaymentCell:
            return .installmentMBB
        case installmentKTCPaymentCell:
            return .installmentKTC
        case installmentKBankPaymentCell:
            return .installmentKBank
        case installmentSCBPaymentCell:
            return .installmentSCB
        case installmentCitiPaymentCell:
            return .installmentCiti
        case installmentTTBPaymentCell:
            return .installmentTTB
        case installmentUOBPaymentCell:
            return .installmentUOB
        case eContextPaymentCell:
            return .eContext
        case mobileBankingSCBPaymentCell:
            return .mobileBankingSCB
        case mobileBankingKBankPaymentCell:
            return .mobileBankingKBank
        case mobileBankingBBLPaymentCell:
            return .mobileBankingBBL
        case mobileBankingBAYPaymentCell:
            return .mobileBankingBAY
        case mobileBankingKTBPaymentCell:
            return .mobileBankingKTB
        case promptpayPaymentCell:
            return .promptPay
        case payPayPaymentCell:
            return .payPay
        case paynowPaymentCell:
            return .payNow
        case truemoneyPaymentCell:
            return .trueMoney
        case truemoneyJumpAppPaymentCell:
            return .trueMoneyJumpApp
        case pointsCitiCell:
            return .pointsCiti
        case fpxCell:
            return .fpx
        case rabbitLinepayCell:
            return .rabbitLinepay
        case OCBCPAOPaymentCell:
            return .mobileBankingOCBCPAO
        case OCBCDigitalPaymentCell:
            return .mobileBankingOCBC
        case grabPayPaymentCell:
            return .grabPay
        case boostPaymentCell:
            return .boost
        case shopeePayPaymentCell:
            return .shopeePay
        case maybankQRPayPaymentCell:
            return .maybankQRPay
        case duitNowQRPaymentCell:
            return .duitNowQR
        case duitNowOBWPaymentCell:
            return .duitNowOBW
        case weChatPaymentCell:
            return .weChat
        default:
            return nil
        }
    }

    // swiftlint:disable:next function_body_length
    func cell(for paymentSource: SourceTypeValue) -> UITableViewCell? {
        switch paymentSource {
        case .internetBankingBAY:
            return internetBankingBAYPaymentCell
        case .internetBankingBBL:
            return internetBankingBBLPaymentCell
        case .alipay:
            return alipayPaymentCell
        case .alipayCN:
            return alipayCNPaymentCell
        case .alipayHK:
            return alipayHKPaymentCell
        case .atome:
            return atomePaymentCell
        case .dana:
            return danaPaymentCell
        case .gcash:
            return gcashPaymentCell
        case .kakaoPay:
            return kakaoPayPaymentCell
        case .touchNGo:
            return touchNGoPaymentCell
        case .billPaymentTescoLotus:
            return billPaymentTescoLotusPaymentCell
        case .installmentBAY:
            return installmentBAYPaymentCell
        case .installmentFirstChoice:
            return installmentFirstChoicePaymentCell
        case .installmentBBL:
            return installmentBBLPaymentCell
        case .installmentMBB:
            return installmentMBBPaymentCell
        case .installmentKTC:
            return installmentKTCPaymentCell
        case .installmentKBank:
            return installmentKBankPaymentCell
        case .installmentSCB:
            return installmentSCBPaymentCell
        case .installmentCiti:
            return installmentCitiPaymentCell
        case .installmentTTB:
            return installmentTTBPaymentCell
        case .installmentUOB:
            return installmentUOBPaymentCell
        case .mobileBankingSCB:
            return mobileBankingSCBPaymentCell
        case .mobileBankingOCBCPAO:
            return OCBCPAOPaymentCell
        case .mobileBankingOCBC:
            return OCBCDigitalPaymentCell
        case .mobileBankingKBank:
            return mobileBankingKBankPaymentCell
        case .mobileBankingBBL:
            return mobileBankingBBLPaymentCell
        case .mobileBankingBAY:
            return mobileBankingBAYPaymentCell
        case .mobileBankingKTB:
            return mobileBankingKTBPaymentCell
        case .eContext:
            return eContextPaymentCell
        case .promptPay:
            return promptpayPaymentCell
        case .payNow:
            return paynowPaymentCell
        case .payPay:
            return payPayPaymentCell
        case .trueMoney:
            return truemoneyPaymentCell
        case .trueMoneyJumpApp:
            return truemoneyJumpAppPaymentCell
        case .pointsCiti:
            return pointsCitiCell
        case .fpx:
            return fpxCell
        case .rabbitLinepay:
            return rabbitLinepayCell
        case .grabPay:
            return grabPayPaymentCell
        case .boost:
            return boostPaymentCell
        case .shopeePay:
            return shopeePayPaymentCell
        case .maybankQRPay:
            return maybankQRPayPaymentCell
        case .duitNowQR:
            return duitNowQRPaymentCell
        case .duitNowOBW:
            return duitNowOBWPaymentCell
        case .weChat:
            return weChatPaymentCell
        default:
            return nil
        }
    }
}
