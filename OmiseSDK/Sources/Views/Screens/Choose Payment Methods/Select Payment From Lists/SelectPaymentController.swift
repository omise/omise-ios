import UIKit

class SelectPaymentController: UITableViewController {

    let viewModel: SelectPaymentPresentableProtocol

    var customizeCellAtIndexPathClosure: (UITableViewCell, IndexPath) -> Void = { _, _ in }

    init(viewModel: SelectPaymentPresentableProtocol) {
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
        setupTableView()
        setupViewModel()

        if let errorMessage = viewModel.errorMessage {
            showErrorMessage(errorMessage)
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
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }

        let viewContext = viewModel.viewContext(at: indexPath.row)

        cell.textLabel?.text = viewContext?.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
        cell.textLabel?.textColor = UIColor.omisePrimary

        cell.detailTextLabel?.text = viewContext?.subtitle
        cell.detailTextLabel?.font = .systemFont(ofSize: 10.0)
        cell.detailTextLabel?.textColor = UIColor(0x8B949E)

        cell.imageView?.image = viewContext?.icon
        cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)

        cell.accessoryView?.tintColor = UIColor.omiseSecondary

        cell.selectionStyle = .default
        cell.selectedBackgroundView = UIView()
            .backgroundColor(UIColor.selectedCellBackgroundColor)

        customizeCellAtIndexPathClosure(cell, indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if viewModel.viewShouldAnimateSelectedCell(at: indexPath.row) {
            startCellActivity(at: indexPath)
        }

        viewModel.viewDidSelectCell(at: indexPath.row) { [indexPath, weak self] in
            guard let self = self else { return }
            self.stopCellActivity(at: indexPath)
            self.view.isUserInteractionEnabled = true
        }
    }
}

extension SelectPaymentController {
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

private extension SelectPaymentController {
    func setupViewModel() {
        viewModel.viewOnDataReloadHandler { [weak tableView] in
            tableView?.reloadData()
        }
    }

    func setupTableView() {
        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64
        tableView.backgroundColor = .background
    }

    func setupNavigationItems() {
        if #available(iOS 11.0, *) {
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
        navigationItem.backBarButtonItem = .empty
    }

    private func showErrorMessage(_ errorMessage: String) {
        let label = UILabel(
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        )

        label.text = errorMessage
        label.textColor = UIColor.omisePrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()

        tableView.backgroundView = label
        tableView.separatorStyle = .none
    }

    private func hideErrorMessage() {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }
}
