import UIKit

extension UIButton {
    @discardableResult
    func title(_ title: String?, for state: UIControl.State) -> Self {
        setTitle(title, for: state)
        return self
    }

    @discardableResult
    func image(_ image: UIImage?, for state: UIControl.State) -> Self {
        setImage(image, for: state)
        return self
    }

    @discardableResult
    func target(_ target: Any?, action: Selector, for event: UIControl.Event) -> Self {
        addTarget(target, action: action, for: event)
        return self
    }

    @discardableResult
    func titleColor(_ color: UIColor?, for state: UIControl.State) -> Self {
        setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func font(_ font: UIFont?) -> Self {
        titleLabel?.font = font
        return self
    }
}
