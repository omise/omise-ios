import UIKit
import os

class ChoosePaymentMethodControllerOld: UITableViewController {
    struct ViewContext: Equatable {
        let icon: UIImage?
        let title: String
        let accessoryIcon: UIImage?
    }

    let viewModel = ChoosePaymentMethodViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64
        applyNavigationBarStyle()
        setupNavigationItems()
        
//        viewModel.onPaymentMethodChanged = { [weak self] in
//            guard let self = self else { return }
//            if self.isViewLoaded {
//                self.tableView.reloadData()
//            }
//        }
//        viewModel.reloadPaymentMethods()
    }

    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        viewModel.numberOfViewContexts
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let identifier = "UITableViewCell"
//        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)
//
//        if cell == nil {
//            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
//        }
//
////        let viewContext = viewModel.viewContext(at: indexPath.row)
//
//        cell.textLabel?.text = viewContext?.title
//        cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
//        cell.textLabel?.textColor = UIColor.omisePrimary
//
//        cell.imageView?.image = viewContext?.icon
//        cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)
//
//        cell.accessoryView?.tintColor = UIColor.omiseSecondary
//
//        return cell
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

        if viewModel.showsActivityForSelectedPaymentMethod(at: indexPath.row) {
            let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
            loadingIndicator.color = UIColor.omiseSecondary
            cell?.accessoryView = loadingIndicator
            loadingIndicator.startAnimating()
            lockUserInferface()
        }

//        viewModel.didSelectPaymentMethod(at: indexPath.row)
    }

    @IBAction private func closeTapped(_ sender: Any) {
//        viewModel.didCancel()
    }
}

extension ChoosePaymentMethodControllerOld {
    func lockUserInferface() {
        view.isUserInteractionEnabled = false
    }

    func unlockUserInterface() {
        view.isUserInteractionEnabled = true
        tableView.reloadData()
    }
}
