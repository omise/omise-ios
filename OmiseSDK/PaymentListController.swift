import UIKit

protocol PaymentListViewModelProtocol {
    var numberOfViewContexts: Int { get }
    var viewNavigationTitle: String { get }
    var viewDisplayLargeTitle: Bool { get }
    var viewShowsCloseButton: Bool { get }

    func viewOnDataReloadHandler(_ handler: @escaping () -> Void)
    func viewContext(at: Int) -> TableCellContext?
    func viewDidSelectCell(at: Int)
    func viewShouldAnimateSelectedCell(at: Int) -> Bool
    func viewDidTapClose()
}

class PaymentListController: UITableViewController {

    let viewModel: PaymentListViewModelProtocol

    init(viewModel: PaymentListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyNavigationBarStyle()
        setupNavigationItems()
        navigationItem.backBarButtonItem = .empty
        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64

        viewModel.viewOnDataReloadHandler { [weak tableView] in
            tableView?.reloadData()
        }
    }

    private func setupNavigationItems() {
        if #available(iOSApplicationExtension 11.0, *) {
            navigationItem.largeTitleDisplayMode = viewModel.viewDisplayLargeTitle ? .always : .never
        }

        navigationItem.title = viewModel.viewNavigationTitle
        if viewModel.viewShowsCloseButton {
            navigationItem.rightBarButtonItem = ClosureBarButtonItem(
                image: UIImage(omise: "Close"),
                style: .plain,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }

    @objc private func didTapClose() {
        viewModel.viewDidTapClose()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfViewContexts
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let viewContext = viewModel.viewContext(at: indexPath.row)

        cell.textLabel?.text = viewContext?.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
        cell.textLabel?.textColor = UIColor.omisePrimary

        cell.imageView?.image = viewContext?.icon
        cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)

        cell.accessoryView?.tintColor = UIColor.omiseSecondary

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if viewModel.viewShouldAnimateSelectedCell(at: indexPath.row) {
            startCellActivity(at: indexPath)
        }

        viewModel.viewDidSelectCell(at: indexPath.row)
    }
}

extension PaymentListController {
    func startCellActivity(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.startAccessoryActivityIndicator()
        view.isUserInteractionEnabled = false
    }

    func stopCellActivity(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
        view.isUserInteractionEnabled = true
    }
}