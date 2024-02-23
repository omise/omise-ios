import Foundation
import UIKit

/// Payment Form Base styles that could be extended by PaymentFormController's subclasses to add additional UI elements styling
/// by adding extentions to the protocol
protocol PaymentFormStyle {
    var buttonBackgroundColor: UIColor { get set }
    var buttonDisabledBackgroundColor: UIColor { get set }
    var buttonTextColor: UIColor { get set }
    var buttonHeight: CGFloat { get set }
    var buttonCornerRadius: CGFloat { get set }

    var textColor: UIColor { get set }
    var sectionTitleColor: UIColor { get set }
    var activityIndicatorColor: UIColor { get set }

    var containerStackSideSpacer: CGFloat { get set }
    var verticalContainerStackSpacer: CGFloat { get set }
    var verticalInputsStackSpacer: CGFloat { get set }
}

struct DefaultPaymentFormStyle: PaymentFormStyle {}

// swiftlint:disable unused_setter_value
extension PaymentFormStyle {
    static func create() -> PaymentFormStyle {
        return DefaultPaymentFormStyle()
    }

    var buttonBackgroundColor: UIColor {
        get { return UIColor(0x1A56F0) }
        set {}
    }

    var buttonDisabledBackgroundColor: UIColor {
        get { return UIColor(0xE4E7ED) }
        set {}
    }

    var buttonTextColor: UIColor {
        get { return UIColor(0xFFFFFF) }
        set {}
    }

    var buttonHeight: CGFloat {
        get { return 48 }
        set {}
    }

    var buttonCornerRadius: CGFloat {
        get { return 4 }
        set {}
    }

    var textColor: UIColor {
        get { return .omisePrimary }
        set {}
    }

    var sectionTitleColor: UIColor {
        get { return UIColor(0x9B9B9B) }
        set {}
    }

    var activityIndicatorColor: UIColor {
        get { return .omisePrimary }
        set {}
    }

    var containerStackSideSpacer: CGFloat {
        get { return CGFloat(18) }
        set {}
    }

    var verticalContainerStackSpacer: CGFloat {
        get { return CGFloat(12) }
        set {}
    }

    var verticalInputsStackSpacer: CGFloat {
        get { return CGFloat(10) }
        set {}
    }
}
// swiftlint:enable unused_setter_value
