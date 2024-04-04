import UIKit

class TapGestureHandler: UITapGestureRecognizer {

    private var action: (() -> Void)?

    convenience init(action: (() -> Void)?) {
        self.init()
        self.action = action
        self.addTarget(self, action: #selector(handleTapGesture))
    }

    @objc private func handleTapGesture() {
        action?()
    }
}
