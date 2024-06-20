import UIKit

public class AdaptableStaticTableViewController<Element: CaseIterable & Equatable>: UITableViewController {
    
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
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let staticIndexPath = calculateStaticIndexPath(fromUIIndexPath: indexPath)
        return super.tableView(tableView, cellForRowAt: staticIndexPath)
    }
    
    public func calculateStaticIndexPath(fromUIIndexPath indexPath: IndexPath) -> IndexPath {
        return staticIndexPath(forValue: element(forUIIndexPath: indexPath))
    }
    
    public func staticIndexPath(forValue value: Element) -> IndexPath {
        let allCases = Element.allCases
        let index = allCases.firstIndex(of: value)! // swiftlint:disable:this force_unwrapping
        return IndexPath(row: allCases.distance(from: allCases.startIndex, to: index), section: 0)
    }
    
    public func element(forUIIndexPath indexPath: IndexPath) -> Element {
        return showingValues[indexPath.row]
    }
}
