import UIKit

public class AdaptableStaticTableViewController<Element: CaseIterable & Equatable>: UITableViewController {
    
    public var showingValues: [Element] = [] {
        didSet {
            reloadIfViewLoaded()
        }
    }

    public typealias TableViewCellCreatedClosure = (
        _ element: Element,
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

        let element = element(forUIIndexPath: indexPath)
        createTableViewCellsClosure?(element, tableView, cell, indexPath)
        return cell
    }
    
    public func element(forUIIndexPath indexPath: IndexPath) -> Element {
        return showingValues[indexPath.row]
    }
}

extension AdaptableStaticTableViewController {
    func reloadIfViewLoaded() {
        if isViewLoaded {
            tableView.reloadData()
        }
    }
}
