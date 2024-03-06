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
                let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            self.contentInset.bottom = keyboardFrame.size.height
        }

        // swiftlint:disable:next line_length
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
            self?.contentInset.bottom = 0
        }

        return self
    }
}
