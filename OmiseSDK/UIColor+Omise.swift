import Foundation
import UIKit

extension UIColor {
    enum Omise: Int {
        case primary = 0x3C414D
        case secondary = 0xE4E7ED
    }

    static var omisePrimary: UIColor {
        UIColor(Omise.primary, dark: Omise.secondary)
    }

    static var omiseSecondary: UIColor {
        UIColor(Omise.secondary, dark: Omise.primary)
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
