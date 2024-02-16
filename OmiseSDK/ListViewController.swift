import UIKit

protocol ListViewControllerProtocol {
    associatedtype Item: Equatable
    var showingValues: [Item] { get }
    func customize(element: Item, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
}

extension ListViewControllerProtocol {
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

/*
public class ListViewController<Item: Equatable>: UITableViewController {
    
    public var showingValues: [Item] = [] {
        didSet {
            reloadIfViewLoaded()
        }
    }

    public typealias TableViewCellCreatedClosure = (
        _ element: Item,
        _ tableView: UITableView,
        _ cell: UITableViewCell,
        _ indexPath: IndexPath
    ) -> Void

    public var createTableViewCellsClosure: TableViewCellCreatedClosure? {
        didSet {
            reloadIfViewLoaded()
        }
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingValues.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let element = item(at: indexPath)
        createTableViewCellsClosure?(element, tableView, cell, indexPath)
        return cell
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        return showingValues[indexPath.row]
    }
}

extension ListViewController {
    func reloadIfViewLoaded() {
        if isViewLoaded {
            tableView.reloadData()
        }
    }
}
*/
