import UIKit
import os

class MobileBankingSourceChooserViewController: AdaptableStaticTableViewController<SourceType>,
                                                PaymentSourceChooser,
                                                PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?

    override var showingValues: [SourceType] {
        didSet {
            os_log("Mobile Banking Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   showingValues.map { $0.rawValue }.joined(separator: ", "))
        }
    }

    @IBOutlet private var mobileBankingNameLabels: [UILabel]!

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

    override func staticIndexPath(forValue value: SourceType) -> IndexPath {
        switch value {
        case .mobileBankingBAY:
            return IndexPath(row: 0, section: 0)
        case .mobileBankingBBL:
            return IndexPath(row: 1, section: 0)
        case .mobileBankingKBank:
            return IndexPath(row: 2, section: 0)
        case .mobileBankingSCB:
            return IndexPath(row: 3, section: 0)
        case .mobileBankingKTB:
            return IndexPath(row: 4, section: 0)
        default:
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
        let sourceType = element(forUIIndexPath: indexPath)

        os_log("Mobile Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, sourceType.rawValue)

        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(.other(sourceType)) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }

    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

        mobileBankingNameLabels.forEach {
            $0.textColor = currentPrimaryColor
        }
    }

    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}
