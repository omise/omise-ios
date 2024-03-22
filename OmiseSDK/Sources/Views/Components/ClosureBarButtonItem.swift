import UIKit

class ClosureBarButtonItem: UIBarButtonItem {
    typealias CompletionHandler = (UIBarButtonItem) -> Void
    private var completionHandler: CompletionHandler?

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, completionHandler: CompletionHandler?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed(sender:)))
        self.completionHandler = completionHandler
        self.target = self
    }

    convenience init(title: String?, style: UIBarButtonItem.Style, completionHandler: CompletionHandler?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed(sender:)))
        self.completionHandler = completionHandler
        self.target = self
    }

    convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, completionHandler: CompletionHandler?) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: #selector(barButtonItemPressed(sender:)))
        self.completionHandler = completionHandler
        self.target = self
    }

    @objc func barButtonItemPressed(sender: UIBarButtonItem) {
        completionHandler?(sender)
    }
}
