import UIKit
import os

class DuitNowOBWBankChooserViewController: UITableViewController,
                                                  PaymentSourceChooser {
    func customize(element bank: Source.PaymentInformation.DuitNowOBW.Bank, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.textLabel?.text = bank.localizedTitle
        cell.imageView?.image = UIImage(omise: bank.iconName)
        cell.accessoryView = UIImageView(image: UIImage(omise: "Next"))

        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = UIColor.omiseSecondary
        }
        cell.accessoryView?.tintColor = UIColor.omiseSecondary
    }
    
    var flowSession: PaymentCreatorFlowSession?
    
    var showingValues: [Source.PaymentInformation.DuitNowOBW.Bank] = [] {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let selectedBank = showingValues[indexPath.row]

        tableView.deselectRow(at: indexPath, animated: true)
        
        os_log("DuitNow OBW Bank List Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBank.description)
        
        let oldAccessoryView = cell.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = UIColor.omiseSecondary
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
            $0.textColor = UIColor.omisePrimary
        }
    }
    
    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}
