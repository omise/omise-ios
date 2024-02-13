import UIKit
import os

class DuitNowOBWBankChooserViewController: AdaptableStaticTableViewController<Source.Payload.DuitNowOBW.Bank>,
                                                  PaymentSourceChooser,
                                                  PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    
    override var showingValues: [Source.Payload.DuitNowOBW.Bank] {
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
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func staticIndexPath(forValue value: Source.Payload.DuitNowOBW.Bank) -> IndexPath {
        switch value {
        case .affin:
            return IndexPath(row: 0, section: 0)
        case .alliance:
            return IndexPath(row: 1, section: 0)
        case .agro:
            return IndexPath(row: 2, section: 0)
        case .ambank:
            return IndexPath(row: 3, section: 0)
        case .cimb:
            return IndexPath(row: 4, section: 0)
        case .islam:
            return IndexPath(row: 5, section: 0)
        case .rakyat:
            return IndexPath(row: 6, section: 0)
        case .muamalat:
            return IndexPath(row: 7, section: 0)
        case .bsn:
            return IndexPath(row: 8, section: 0)
        case .hongleong:
            return IndexPath(row: 9, section: 0)
        case .hsbc:
            return IndexPath(row: 10, section: 0)
        case .kfh:
            return IndexPath(row: 11, section: 0)
        case .maybank2u:
            return IndexPath(row: 12, section: 0)
        case .ocbc:
            return IndexPath(row: 13, section: 0)
        case .publicBank:
            return IndexPath(row: 14, section: 0)
        case .rhb:
            return IndexPath(row: 15, section: 0)
        case .sc:
            return IndexPath(row: 16, section: 0)
        case .uob:
            return IndexPath(row: 17, section: 0)
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let selectedBank = element(forUIIndexPath: indexPath)
        let payload = Source.Payload.duitNowOBW(.init(bank: selectedBank))

        tableView.deselectRow(at: indexPath, animated: true)
        
        os_log("DuitNow OBW Bank List Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBank.description)
        
        let oldAccessoryView = cell.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        flowSession?.requestCreateSource(payload) { [weak self] _ in
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
