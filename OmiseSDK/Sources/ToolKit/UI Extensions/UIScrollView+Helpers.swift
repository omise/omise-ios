import UIKit

extension UIScrollView {
    @discardableResult
    func adjustContentInsetOnKeyboardAppear() -> Self {
        // swiftlint:disable:next line_length
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            guard
                let self = self,
                self.window != nil,
                let userInfo = notification.userInfo,
                let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let keyboardFrameBegin = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
                keyboardFrame != keyboardFrameBegin else {
                return
            }

            self.contentInset.bottom = keyboardFrame.size.height

            let bottomScrollIndicatorInset: CGFloat
            if #available(iOS 11.0, *) {
                bottomScrollIndicatorInset = keyboardFrame.height - safeAreaInsets.bottom
            } else {
                bottomScrollIndicatorInset = keyboardFrame.height
            }
            
            scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
        }

        // swiftlint:disable:next line_length
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
            self?.contentInset.bottom = 0
            self?.scrollIndicatorInsets.bottom = 0.0
        }

        return self
    }
}
