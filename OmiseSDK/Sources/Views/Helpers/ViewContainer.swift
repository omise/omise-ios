import UIKit.UIView

class ViewContainer: UIView {
    let object: Any
    init(_ object: Any) {
        self.object = object
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
