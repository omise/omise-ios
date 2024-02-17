import UIKit
import os

class MobileBankingSourceChooserViewController: UITableViewController,
                                                PaymentSourceChooser {
    func customize(element: SourceType, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
//                    cell.textLabel?.text = title(for: paymentOption.so)
//                    cell.imageView?.image = paymentOption.listIcon
        cell.accessoryView = UIImageView(image: UIImage(named: "Next"))

        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = UIColor.omiseSecondary
        }
        cell.accessoryView?.tintColor = UIColor.omiseSecondary
    }
    
    var flowSession: PaymentCreatorFlowSession?

    var showingValues: [SourceType] = [] {
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
//        applyPrimaryColor()
//        applySecondaryColor()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func title(for sourceType: SourceType) -> String? {
        switch sourceType {
        case .mobileBankingSCB: return "SCB EASY"
        case .mobileBankingKBank: return "K PLUS"
        case .mobileBankingBAY: return "KMA"
        case .mobileBankingBBL: return "Bualuang mBanking"
        case .mobileBankingKTB: return "Krungthai Next"
        default: return nil
        }
    }

    func icon(for sourceType: SourceType) -> UIImage? {
        switch sourceType {
        case .mobileBankingSCB: return UIImage(named: "SCB", in: .omiseSDK, compatibleWith: nil)
        case .mobileBankingKBank: return UIImage(named: "KPlus", in: .omiseSDK, compatibleWith: nil)
        case .mobileBankingBAY: return UIImage(named: "KMA", in: .omiseSDK, compatibleWith: nil)
        case .mobileBankingBBL: return UIImage(named: "BBL M", in: .omiseSDK, compatibleWith: nil)
        case .mobileBankingKTB: return UIImage(named: "KTB Next", in: .omiseSDK, compatibleWith: nil)
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = UIColor.omiseSecondary
        }
        cell.accessoryView?.tintColor = UIColor.omiseSecondary
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let sourceType = showingValues[indexPath.row]

        os_log("Mobile Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, sourceType.rawValue)

        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = UIColor.omiseSecondary
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

        mobileBankingNameLabels.forEach {
            $0.textColor = UIColor.omisePrimary
        }
    }

    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}
