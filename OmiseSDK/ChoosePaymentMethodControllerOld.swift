import UIKit
import os

class ChoosePaymentMethodController: TableListController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64
        applyNavigationBarStyle()
        setupNavigationItems()
    }

    private func setupNavigationItems() {
        if #available(iOSApplicationExtension 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        navigationItem.backBarButtonItem = .empty
        navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

        startCellActivity(at: indexPath)
//        if viewModel.showsActivityForSelectedPaymentMethod(at: indexPath.row) {
//            let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
//            loadingIndicator.color = UIColor.omiseSecondary
//            cell?.accessoryView = loadingIndicator
//            loadingIndicator.startAnimating()
//            lockUserInferface()
//        }

//        viewModel.didSelectPaymentMethod(at: indexPath.row)
    }

    @IBAction private func closeTapped(_ sender: Any) {
//        viewModel.didCancel()
    }
}
