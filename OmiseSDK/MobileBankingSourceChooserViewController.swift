import UIKit
import os


@objc(OMSMobileBankingSourceChooserViewController)
class MobileBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.MobileBanking>, PaymentSourceChooser, PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?

    override var showingValues: [PaymentInformation.MobileBanking] {
        didSet {
            if #available(iOSApplicationExtension 10.0, *) {
                os_log("Mobile Banking Chooser: Showing options - %{private}@", log: uiLogObject, type: .info, showingValues.map({ $0.description }).joined(separator: ", "))
            }
        }
    }


    @IBOutlet var mobileBankingNameLabels: [UILabel]!

    @IBInspectable @objc public var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }

    @IBInspectable @objc public var preferredSecondaryColor: UIColor? {
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

    override func staticIndexPath(forValue value: PaymentInformation.MobileBanking) -> IndexPath {
        switch value {
        case .scb:
            return IndexPath(row: 0, section: 0)
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

        if #available(iOSApplicationExtension 10.0, *) {
            os_log("Mobile Banking Chooser: %{private}@ was selected", log: uiLogObject, type: .info, bank.description)
        }

        let oldAccessoryView = cell?.accessoryView
        #if swift(>=4.2)
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        #else
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        #endif
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(.mobileBanking(bank), completionHandler: { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        })
    }

    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

        mobileBankingNameLabels.forEach({
            $0.textColor = currentPrimaryColor
        })
    }

    private func applySecondaryColor() {}
}


