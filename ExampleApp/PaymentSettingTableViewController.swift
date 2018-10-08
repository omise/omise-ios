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
    
    @objc var currentAmount: Int64 = 0
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
    @objc(currentCurrencyCode)
    var __currentCurrencyCode: String {
        get {
            return currentCurrency.code
        }
        set {
            currentCurrency = Currency(code: newValue)
        }
    }
    
    @objc var allowedPaymentMethods: Set<OMSSourceTypeValue> = [] {
        willSet {
            guard isViewLoaded else {
                return
            }
            let removingPaymentMethods = allowedPaymentMethods.subtracting(newValue)
            removingPaymentMethods.compactMap(self.cell(for:)).forEach({
                $0.accessoryType = .none
            })
        }
        didSet {
            guard isViewLoaded else {
                return
            }
            let addingPaymentMethods = allowedPaymentMethods.subtracting(oldValue)
            addingPaymentMethods.compactMap(self.cell(for:)).forEach({
                $0.accessoryType = .checkmark
            })
        }
    }
    
    @IBOutlet var amountField: UITextField!
    @IBOutlet var amountFieldInputAccessoryView: UIToolbar!
    
    @IBOutlet var thbCurrencyCell: UITableViewCell!
    @IBOutlet var jpyCurrencyCell: UITableViewCell!
    @IBOutlet var usdCurrencyCell: UITableViewCell!
    
    @IBOutlet var internetBankingBAYPaymentCell: UITableViewCell!
    @IBOutlet var internetBankingKTBPaymentCell: UITableViewCell!
    @IBOutlet var internetBankingSCBPaymentCell: UITableViewCell!
    @IBOutlet var internetBankingBBLPaymentCell: UITableViewCell!
    @IBOutlet var alipayPaymentCell: UITableViewCell!
    @IBOutlet var billPaymentTescoLotusPaymentCell: UITableViewCell!
    @IBOutlet var installmentBAYPaymentCell: UITableViewCell!
    @IBOutlet var installmentFirstChoicePaymentCell: UITableViewCell!
    @IBOutlet var installmentBBLPaymentCell: UITableViewCell!
    @IBOutlet var installmentKTCPaymentCell: UITableViewCell!
    @IBOutlet var installmentKBankPaymentCell: UITableViewCell!
    @IBOutlet var eContextPaymentCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cell(for: currentCurrency)?.accessoryType = .checkmark
        allowedPaymentMethods.compactMap(self.cell(for:)).forEach({
            $0.accessoryType = .checkmark
        })
        
        amountField.text = amountFormatter.string(from: NSNumber(value: currentCurrency.convert(fromSubunit: currentAmount)))
        amountField.inputAccessoryView = amountFieldInputAccessoryView
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
    @IBAction func finishEditingAmount(_ sender: Any) {
        amountField.resignFirstResponder()
    }
    
    @IBAction func showPresetChooser(_ sender: Any) {
        let presetChooserAlertController = UIAlertController(title: "Preset", message: nil, preferredStyle: .actionSheet)
        presetChooserAlertController.addAction(UIAlertAction(title: "Thailand", style: .default, handler: { (_) in
            self.currentAmount = PaymentPreset.thailandPreset.paymentAmount
            self.currentCurrency = PaymentPreset.thailandPreset.paymentCurrency
            self.allowedPaymentMethods = Set(PaymentPreset.thailandPreset.allowedPaymentMethods)
        }))
        presetChooserAlertController.addAction(UIAlertAction(title: "Japan", style: .default, handler: { (_) in
            self.currentAmount = PaymentPreset.japanPreset.paymentAmount
            self.currentCurrency = PaymentPreset.japanPreset.paymentCurrency
            self.allowedPaymentMethods = Set(PaymentPreset.japanPreset.allowedPaymentMethods)
        }))
        
        presetChooserAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(presetChooserAlertController, animated: true, completion: nil)
    }
}

extension PaymentSettingTableViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        #if swift(>=4.2)
        return string.allSatisfy({ (character) -> Bool in
            return "0"..."9" ~= character || (currentCurrency.factor > 1 && "." == character)
        })
        #else
        return !string.contains(where: { (character) -> Bool in
            return !("0"..."9" ~= character || (currentCurrency.factor > 1 && "." == character))
        })
        #endif
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
        default: return nil
        }
    }
    
    func paymentSource(for cell: UITableViewCell) -> OMSSourceTypeValue? {
        switch cell {
        case internetBankingBAYPaymentCell:
            return .internetBankingBAY
        case internetBankingKTBPaymentCell:
            return .internetBankingKTB
        case internetBankingSCBPaymentCell:
            return .internetBankingSCB
        case internetBankingBBLPaymentCell:
            return .internetBankingBBL
        case alipayPaymentCell:
            return .alipay
        case billPaymentTescoLotusPaymentCell:
            return .billPaymentTescoLotus
        case installmentBAYPaymentCell:
            return .installmentBAY
        case installmentFirstChoicePaymentCell:
            return .installmentFirstChoice
        case installmentBBLPaymentCell:
            return .installmentBBL
        case installmentKTCPaymentCell:
            return .installmentKTC
        case installmentKBankPaymentCell:
            return .installmentKBank
        case eContextPaymentCell:
            return .eContext
        default:
            return nil
        }
    }
    
    func cell(for paymentSource: OMSSourceTypeValue) -> UITableViewCell? {
        switch paymentSource {
        case .internetBankingBAY:
            return internetBankingBAYPaymentCell
        case .internetBankingKTB:
            return internetBankingKTBPaymentCell
        case .internetBankingSCB:
            return internetBankingSCBPaymentCell
        case .internetBankingBBL:
            return internetBankingBBLPaymentCell
        case .alipay:
            return alipayPaymentCell
        case .billPaymentTescoLotus:
            return billPaymentTescoLotusPaymentCell
        case .installmentBAY:
            return installmentBAYPaymentCell
        case .installmentFirstChoice:
            return installmentFirstChoicePaymentCell
        case .installmentBBL:
            return installmentBBLPaymentCell
        case .installmentKTC:
            return installmentKTCPaymentCell
        case .installmentKBank:
            return installmentKBankPaymentCell
        case .eContext:
            return eContextPaymentCell
        default:
            return nil
        }
    }
}

