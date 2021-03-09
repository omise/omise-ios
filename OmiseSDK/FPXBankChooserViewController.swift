import UIKit
import os


@objc(OMSFPXBankChooserViewController)
class FPXBankChooserViewController: AdaptableDynamicTableViewController<Capability.Backend.Bank>, PaymentSourceChooser, PaymentChooserUI {
    var email: String?
    var flowSession: PaymentCreatorFlowSession?
    private let defaultImage: String = "FPX/unknown"
    private let message = NSLocalizedString(
        "fpx.bank-chooser.no-banks-available.text",
        bundle: Bundle.omiseSDKBundle,
        value: "Cannot retrieve list of banks.\nPlease try again later.",
        comment: "A descriptive text telling the user when there's no banks available"
    )

    override var showingValues: [Capability.Backend.Bank] {
        didSet {
            os_log("FPX Bank Chooser: Showing options - %{private}@", log: uiLogObject, type: .info, showingValues.map({ $0.name }).joined(separator: ", "))
        }
    }

    @IBInspectable @objc var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }

    @IBInspectable @objc var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyPrimaryColor()
        applySecondaryColor()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if showingValues.count == 0 {
            displayEmptyMessage()
        } else {
            restore()
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        let bank = showingValues[indexPath.row]
        cell.accessoryView?.tintColor = currentSecondaryColor
        cell.textLabel?.text = bank.name
        cell.imageView?.image = bankImage(bank: bank.code)
        cell.textLabel?.textColor = currentPrimaryColor

        if !bank.active {
            disableCell(cell: cell)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let selectedBank = element(forUIIndexPath: indexPath)
        let paymentInformation = PaymentInformation.FPX(bank: selectedBank.code, email: email!)

        tableView.deselectRow(at: indexPath, animated: true)

        os_log("FPX Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBank.name)

        let oldAccessoryView = cell.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(.fpx(paymentInformation), completionHandler: { _ in
            cell.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        })
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
    }

    private func applySecondaryColor() {
    }

    private func bankImage(bank: String) -> UIImage? {
        if let image = UIImage(named: "FPX/" + bank, in: Bundle.omiseSDKBundle, compatibleWith: nil) {
            return image
        } else {
            return UIImage(named: defaultImage, in: Bundle.omiseSDKBundle, compatibleWith: nil)
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
        label.textColor = currentPrimaryColor
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

