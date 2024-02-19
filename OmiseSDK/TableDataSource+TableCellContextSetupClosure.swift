import UIKit

extension TableDataSource where T == TableCellContext {
    func createDefaultCellSetupClosure() -> CellSetupClosure {
        { _, cell, _, viewContext in
            cell.textLabel?.text = viewContext?.title
            cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
            cell.textLabel?.textColor = UIColor.omisePrimary

            cell.imageView?.image = viewContext?.icon

            cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)
            cell.accessoryView?.tintColor = UIColor.omiseSecondary
        }
    }
}
