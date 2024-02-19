import UIKit

class TableDataSource<T>: NSObject, UITableViewDataSource, ViewAttachable {
    typealias CellSetupClosure = (_ tableView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath, _ value: T?) -> Void

    var cellSetupClosure: CellSetupClosure? {
        didSet {
            tableView.reloadData()
        }
    }

    var values: [T] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let tableView: UITableView

    init(tableView: UITableView, _ values: [T] = []) {
        self.tableView = tableView
        self.values = values
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let value = values.at(indexPath.row)
        cellSetupClosure?(tableView, cell, indexPath, value)
        return cell
    }
}
