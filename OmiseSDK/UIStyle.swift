import Foundation
import UIKit

enum UIStyle {
    enum Color: Int {
        case primary = 0x3C414D
        case secondary = 0xE4E7ED
    }
}

extension UIStyle.Color {
    var uiColor: UIColor {
        UIColor(self.rawValue)
    }
}
