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
            bottomScrollIndicatorInset = keyboardFrame.height - self.safeAreaInsets.bottom
            self.verticalScrollIndicatorInsets.bottom = bottomScrollIndicatorInset
        }

        // swiftlint:disable:next line_length
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
            self?.contentInset.bottom = 0
            self?.verticalScrollIndicatorInsets.bottom = 0.0
        }

        return self
    }
}
