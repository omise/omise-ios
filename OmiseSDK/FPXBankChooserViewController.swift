import UIKit
import os

class FPXBankChooserViewController: AdaptableDynamicTableViewController<Capability.PaymentMethod.Bank>, PaymentSourceChooser {
    var email: String?
    var flowSession: PaymentCreatorFlowSession?
    private let defaultImage: String = "FPX/unknown"
    private let message = NSLocalizedString(
        "fpx.bank-chooser.no-banks-available.text",
        bundle: .omiseSDK,
        value: "Cannot retrieve list of banks.\nPlease try again later.",
        comment: "A descriptive text telling the user when there's no banks available"
    )

    override var showingValues: [Capability.PaymentMethod.Bank] {
        didSet {
            os_log("FPX Bank Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   showingValues.map { $0.name }.joined(separator: ", "))
        }
    }

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

        if showingValues.isEmpty {
            displayEmptyMessage()
        } else {
            restore()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = UIColor.omiseSecondary
        }
        let bank = showingValues[indexPath.row]
        cell.accessoryView?.tintColor = UIColor.omiseSecondary
        cell.textLabel?.text = bank.name
        cell.imageView?.image = bankImage(bank: bank.code)
        cell.textLabel?.textColor = UIColor.omisePrimary

        if !bank.isActive {
            disableCell(cell: cell)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let selectedBank = item(at: indexPath)
        guard let bank = PaymentInformation.FPX.Bank(rawValue: selectedBank.code) else {
            return
        }

        let paymentInformation = PaymentInformation.fpx(.bank(bank, email: email))

        tableView.deselectRow(at: indexPath, animated: true)

        os_log("FPX Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBank.name)

        let oldAccessoryView = cell.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = UIColor.omiseSecondary
        cell.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(paymentInformation) { [weak self] _ in
            guard let self = self else { return }
            cell.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
    }

    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }

    private func bankImage(bank: String) -> UIImage? {
        if let image = UIImage(named: "FPX/" + bank, in: .omiseSDK, compatibleWith: nil) {
            return image
        } else {
            return UIImage(named: defaultImage, in: .omiseSDK, compatibleWith: nil)
        }
    }

    private func disableCell(cell: UITableViewCell) {
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.contentView.alpha = 0.5
        cell.isUserInteractionEnabled = false
    }

    private func displayEmptyMessage() {
        let label = UILabel(
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        )

        label.text = message
        label.textColor = UIColor.omisePrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()

        tableView.backgroundView = label
        tableView.separatorStyle = .none
    }

    private func restore() {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }
}
