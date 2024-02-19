import UIKit

class TableDelegate: NSObject, UITableViewDelegate, ViewAttachable {
    typealias DidSelectSellClosure = (_ tableView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void

    var didSelectCellClosure: DidSelectSellClosure?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectCellClosure?(tableView, cell, indexPath)
    }
}
