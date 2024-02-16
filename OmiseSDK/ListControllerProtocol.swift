import UIKit

protocol ListControllerProtocol {
    associatedtype Item: Equatable
    var showingValues: [Item] { get }
    func customize(element: Item, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
}

extension ListControllerProtocol {
    public func item(at indexPath: IndexPath) -> Item {
        return showingValues[indexPath.row]
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingValues.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let element = item(at: indexPath)
        customize(element: element, tableView: tableView, cell: cell, indexPath: indexPath)
        return cell
    }
}
