import UIKit
import os

class DuitNowOBWBankChooserViewController: AdaptableStaticTableViewController<PaymentInformation.DuitNowOBW.Bank>,
                                                  PaymentSourceChooser,
                                                  PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    
    override var showingValues: [PaymentInformation.DuitNowOBW.Bank] {
        didSet {
            os_log("DuitNow OBW Bank Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   showingValues.map { $0.description }.joined(separator: ", "))
        }
    }

    @IBOutlet private var bankNameLabels: [UILabel]!
    
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
        setupTableViewCells()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupTableViewCells() {
        createTableViewCellsClosure = { [weak self] bank, _, cell, _ in
            guard let self = self else { return }
            cell.textLabel?.text = bank.localizedTitle
            cell.imageView?.image = bank.listIcon
            cell.accessoryView = UIImageView(image: UIImage(named: "Next"))

            if let cell = cell as? PaymentOptionTableViewCell {
                cell.separatorView.backgroundColor = self.currentSecondaryColor
            }
            cell.accessoryView?.tintColor = self.currentSecondaryColor

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let selectedBank = element(forUIIndexPath: indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
        
        os_log("DuitNow OBW Bank List Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBank.description)
        
        let oldAccessoryView = cell.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        flowSession?.requestCreateSource(.duitNowOBW(.bank(selectedBank))) { [weak self] _ in
            guard let self = self else { return }
            cell.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        bankNameLabels.forEach {
            $0.textColor = currentPrimaryColor
        }
    }
    
    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}

extension PaymentInformation.DuitNowOBW.Bank {
    var localizedTitle: String {
        switch self {
        case .affin:
            return "Affin Bank"
        case .alliance:
            return "Alliance Bank"
        case .agro:
            return "Agrobank"
        case .ambank:
            return "AmBank"
        case .islam:
            return "Bank Islam"
        case .muamalat:
            return "Bank Muamalat"
        case .rakyat:
            return "Bank Rakyat"
        case .bsn:
            return "Bank Simpanan Nasional"
        case .cimb:
            return "CIMB Bank"
        case .hongleong:
            return "Hong Leong"
        case .hsbc:
            return "HSBC Bank"
        case .kfh:
            return "Kuwait Finance House"
        case .maybank2u:
            return "Maybank"
        case .ocbc:
            return "OCBC"
        case .publicBank:
            return "Public Bank"
        case .rhb:
            return "RHB Bank"
        case .sc:
            return "Standard Chartered"
        case .uob:
            return "United Overseas Bank"
        }
    }

    var listIcon: UIImage? {
        switch self {
        case .affin:
            return UIImage(named: "FPX/affin")
        case .alliance:
            return UIImage(named: "FPX/alliance")
        case .agro:
            return UIImage(named: "agrobank")
        case .ambank:
            return UIImage(named: "FPX/ambank")
        case .islam:
            return UIImage(named: "FPX/islam")
        case .muamalat:
            return UIImage(named: "FPX/muamalat")
        case .rakyat:
            return UIImage(named: "FPX/rakyat")
        case .bsn:
            return UIImage(named: "FPX/bsn")
        case .cimb:
            return UIImage(named: "FPX/cimb")
        case .hongleong:
            return UIImage(named: "FPX/hong-leong")
        case .hsbc:
            return UIImage(named: "FPX/hsbc")
        case .kfh:
            return UIImage(named: "FPX/kfh")
        case .maybank2u:
            return UIImage(named: "FPX/maybank")
        case .ocbc:
            return UIImage(named: "FPX/ocbc")
        case .publicBank:
            return UIImage(named: "FPX/public-bank")
        case .rhb:
            return UIImage(named: "FPX/rhb")
        case .sc:
            return UIImage(named: "FPX/sc")
        case .uob:
            return UIImage(named: "FPX/uob")
        }
    }
}
