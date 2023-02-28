import UIKit
import os

@objc(OMSInternetBankingSourceChooserViewController)
// swiftlint:disable:next type_name attributes
class InternetBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.InternetBanking>,
                                                  PaymentSourceChooser,
                                                  PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    
    override var showingValues: [PaymentInformation.InternetBanking] {
        didSet {
            os_log("Internet Banking Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   showingValues.map { $0.description }.joined(separator: ", "))
        }
    }
    
    @IBOutlet var internetBankingNameLabels: [UILabel]!
    
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
    
    override func staticIndexPath(forValue value: PaymentInformation.InternetBanking) -> IndexPath {
        switch value {
        case .bbl:
            return IndexPath(row: 0, section: 0)
        case .bay:
            return IndexPath(row: 1, section: 0)
        case .other:
            preconditionFailure("This value is not supported for the built-in chooser")
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
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let bank = element(forUIIndexPath: indexPath)
        
        os_log("Internet Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, bank.description)
        
        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        flowSession?.requestCreateSource(.internetBanking(bank)) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        internetBankingNameLabels.forEach {
            $0.textColor = currentPrimaryColor
        }
    }
    
    private func applySecondaryColor() {}
}
