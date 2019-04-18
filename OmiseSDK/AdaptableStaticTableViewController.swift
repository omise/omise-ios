import UIKit


#if swift(>=4.2)
public typealias StaticElementIterable = CaseIterable
#else
public protocol StaticElementIterable {
    /// A type that can represent a collection of all values of this type.
    associatedtype AllCases : Collection where Self.AllCases.Element == Self
    
    /// A collection of all values of this type.
    static var allCases: Self.AllCases { get }
}
#endif


public class AdaptableStaticTableViewController<Element: StaticElementIterable & Equatable>: UITableViewController {
    
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
        let index = allCases.firstIndex(of: value)!
        return IndexPath(row: allCases.distance(from: allCases.startIndex, to: index), section: 0)
    }
    
    public func element(forUIIndexPath indexPath: IndexPath) -> Element {
        return showingValues[indexPath.row]
    }
}

