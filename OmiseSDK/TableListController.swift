import UIKit

class TableListController: UITableViewController {

    var items: [TableCellContext] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var didSelectCellHandler: (UITableViewCell, IndexPath) -> Void = { _, _ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyNavigationBarStyle()

        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64
    }

    func lockUserInferface() {
        view.isUserInteractionEnabled = false
    }

    func unlockUserInterface() {
        view.isUserInteractionEnabled = true
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let viewContext = items.at(indexPath.row)

        cell.textLabel?.text = viewContext?.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
        cell.textLabel?.textColor = UIColor.omisePrimary

        cell.imageView?.image = viewContext?.icon
        cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)

        cell.accessoryView?.tintColor = UIColor.omiseSecondary

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)

        didSelectCellHandler(cell, indexPath)
    }
}

extension TableListController {

}
