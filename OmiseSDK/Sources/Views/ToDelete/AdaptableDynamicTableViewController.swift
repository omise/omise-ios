import UIKit

public class AdaptableDynamicTableViewController<Item: Equatable>: UITableViewController {
    
    public var showingValues: [Item] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingValues.count
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        return showingValues[indexPath.row]
    }
}
