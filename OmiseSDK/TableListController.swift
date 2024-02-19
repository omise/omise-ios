import UIKit

class TableListController: UITableViewController {

    var prefersLargeTitles = false {
        didSet {
            if isViewLoaded {
                updateNavigationBarLargeTitles()
            }
        }
    }

    func updateNavigationBarLargeTitles() {
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        }
    }

    /// Initialization code that requires access to navigationController
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        updateNavigationBarLargeTitles()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyNavigationBarStyle()
        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64

//        viewModel.onPaymentMethodChanged = { [weak self] in
//            guard let self = self else { return }
//            if self.isViewLoaded {
//                self.tableView.reloadData()
//            }
//        }
//        viewModel.reloadPaymentMethods()
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
//        let viewContext = viewModel.viewContext(at: indexPath.row)
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

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if viewModel.showsActivityOnPaymentMethodSelected(at: indexPath.row) {
//            let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
//            loadingIndicator.color = UIColor.omiseSecondary
//            cell?.accessoryView = loadingIndicator
//            loadingIndicator.startAnimating()
//            lockUserInferface()
//        }
//
//        viewModel.didSelectPaymentMethod(at: indexPath.row)
//    }

//    @IBAction private func closeTapped(_ sender: Any) {
//        viewModel.didCancel()
//    }
}

extension TableListController {
    func lockUserInferface() {
        view.isUserInteractionEnabled = false
    }

    func unlockUserInterface() {
        view.isUserInteractionEnabled = true
        tableView.reloadData()
    }
}
