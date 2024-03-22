import Foundation
import UIKit

extension UIColor {
    enum Omise: Int {
        case primary = 0x3C414D
        case secondary = 0xE4E7ED
        case darkBackground = 0x1C1C1E
        case lightBackground = 0xFFFFFF
    }

    static var omiseBackground: UIColor {
        UIColor(.lightBackground, dark: .darkBackground)
    }

    static var omisePrimary: UIColor {
        UIColor(.primary, dark: .secondary)
    }

    static var omiseSecondary: UIColor {
        UIColor(.secondary, dark: .primary)
    }

    convenience init(_ light: Omise, dark: Omise) {
        if #available(iOS 13, *) {
            // swiftlint:disable trailing_closure
            self.init(dynamicProvider: { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? UIColor(dark.rawValue) : UIColor(light.rawValue)
            })
            // swiftlint:enable trailing_closure
        } else {
            self.init(light.rawValue)
        }
    }
}
