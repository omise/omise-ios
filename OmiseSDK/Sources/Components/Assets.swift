import Foundation
import UIKit.UIImage

enum Assets {
    enum Icon: String {
        case next = "Next"
        case redirect = "Redirect"
    }
}

extension UIImage {
    convenience init?(_ icon: Assets.Icon?) {
        guard let icon = icon else { return nil }
        self.init(named: icon.rawValue, in: .omiseSDK, compatibleWith: nil)
    }
}
