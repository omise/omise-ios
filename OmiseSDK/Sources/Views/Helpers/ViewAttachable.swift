import UIKit.UIView

/// Explicit mark a class that will be store inside another View to retain a life circle
/// and be deallocated together with the view it's attached
protocol ViewAttachable {
}

extension UIView {
    func attach(_ object: ViewAttachable) {
        addSubview(ViewContainer(object))
    }
}

extension UIViewController {
    func attach(_ object: ViewAttachable) {
        view.addSubview(ViewContainer(object))
    }
}
