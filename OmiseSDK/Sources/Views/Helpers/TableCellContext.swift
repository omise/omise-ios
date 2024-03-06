import UIKit

struct TableCellContext: Equatable {
    let icon: UIImage?
    let title: String
    let subtitle: String?
    let accessoryIcon: UIImage?

    init(title: String, subtitle: String? = nil, icon: UIImage? = nil, accessoryIcon: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accessoryIcon = accessoryIcon
    }
}
