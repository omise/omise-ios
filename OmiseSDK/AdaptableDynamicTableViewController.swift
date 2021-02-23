import UIKit


public class AdaptableDynamicTableViewController<Element: Equatable>: UITableViewController {
    
    public var showingValues: [Element] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingValues.count
    }
//    
//    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let staticIndexPath = calculateStaticIndexPath(fromUIIndexPath: indexPath)
//        return super.tableView(tableView, cellForRowAt: staticIndexPath)
//    }
    
    public func element(forUIIndexPath indexPath: IndexPath) -> Element {
        return showingValues[indexPath.row]
    }
}

