import UIKit
import os

// swiftlint:disable:next type_name
class InternetBankingSourceChooserViewController: UITableViewController, ListViewControllerProtocol,
                                                  PaymentSourceChooser,
                                                  PaymentChooserUI {
    
    var flowSession: PaymentCreatorFlowSession?
    
    var showingValues: [SourceType] = [] {
        didSet {
            os_log("Internet Banking Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   showingValues.map { $0.rawValue }.joined(separator: ", "))
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
    
    func customize(element: SourceType, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        cell.accessoryView?.tintColor = currentSecondaryColor
    }

    // TODO: Add implementation for ListViewController
/*
    override func staticIndexPath(forValue value: SourceType) -> IndexPath {
        switch value {
        case .internetBankingBBL:
            return IndexPath(row: 0, section: 0)
        case .internetBankingBAY:
            return IndexPath(row: 1, section: 0)
        default:
            preconditionFailure("This value is not supported for the built-in chooser")
        }
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let sourceType = item(at: indexPath)

        os_log("Internet Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, sourceType.rawValue)

        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        flowSession?.requestCreateSource(.sourceType(sourceType)) { _ in
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
    
    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}
