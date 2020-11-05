import Foundation
import UIKit


#if swift(>=4.2)
typealias ControlState = UIControl.State
typealias AttributedStringKey = NSAttributedString.Key
typealias ViewAnimationOptions = UIView.AnimationOptions
typealias TableViewCellStyle = UITableViewCell.CellStyle
typealias ApplicationLaunchOptionsKey = UIApplication.LaunchOptionsKey
typealias AlertActionStyle = UIAlertAction.Style

@available(iOS 10.0, *)
typealias AccessibilityCustomRotorDirection = UIAccessibilityCustomRotor.Direction

let ViewLayoutFittingCompressedSize = UIView.layoutFittingCompressedSize

let NavigationControllerHideShowBarDuration: CGFloat = UINavigationController.hideShowBarDuration

let NotificationKeyboardWillChangeFrameNotification: NSNotification.Name = UIResponder.keyboardWillChangeFrameNotification
let NotificationKeyboardWillHideFrameNotification: NSNotification.Name = UIResponder.keyboardWillHideNotification
let NotificationKeyboardWillShowFrameNotification: NSNotification.Name = UIResponder.keyboardWillShowNotification

let NotificationKeyboardFrameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
let NotificationKeyboardFrameBeginUserInfoKey = UIResponder.keyboardFrameBeginUserInfoKey

let AccessibilityNotificationAnnouncement = UIAccessibility.Notification.announcement
#else
typealias ControlState = UIControlState
typealias AttributedStringKey = NSAttributedStringKey
typealias ViewAnimationOptions = UIViewAnimationOptions
typealias TableViewCellStyle = UITableViewCellStyle
typealias AccessibilityCustomRotorDirection = UIAccessibilityCustomRotorDirection
typealias ApplicationLaunchOptionsKey = UIApplicationLaunchOptionsKey
typealias AlertActionStyle = UIAlertActionStyle

let NavigationControllerHideShowBarDuration: CGFloat = UINavigationControllerHideShowBarDuration

let NotificationKeyboardWillChangeFrameNotification: NSNotification.Name = NSNotification.Name.UIKeyboardWillChangeFrame
let NotificationKeyboardWillHideFrameNotification: NSNotification.Name = NSNotification.Name.UIKeyboardWillHide
let NotificationKeyboardWillShowFrameNotification: NSNotification.Name = NSNotification.Name.UIKeyboardWillShow

let NotificationKeyboardFrameEndUserInfoKey = UIKeyboardFrameEndUserInfoKey
let NotificationKeyboardFrameBeginUserInfoKey = UIKeyboardFrameBeginUserInfoKey

let AccessibilityNotificationAnnouncement = UIAccessibilityAnnouncementNotification

let ViewLayoutFittingCompressedSize = UILayoutFittingCompressedSize

extension CGRect {
    func inset(by insets: UIEdgeInsets) -> CGRect {
        return UIEdgeInsetsInsetRect(self, insets)
    }
}

enum UIAccessibility {
    static func post(notification: UIAccessibilityNotifications, argument: Any?) {
        UIAccessibilityPostNotification(notification, argument)
    }
    
    static func convertToScreenCoordinates(_ rect: CGRect, in view: UIView) -> CGRect {
        return UIAccessibilityConvertFrameToScreenCoordinates(rect, view)
    }
}

extension String {
    func firstIndex(of character: String.Element) -> String.Index? {
        return index(of: character)
    }
}
#endif

