import UIKit

extension UIImage {
    convenience init?(omise: String) {
        self.init(named: omise, in: .omiseSDK, compatibleWith: nil)
    }

}
