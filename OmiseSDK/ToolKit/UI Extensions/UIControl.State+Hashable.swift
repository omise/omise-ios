import UIKit
/// ref: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0364-retroactive-conformance-warning.md
/// if we support iOS 13 and above, can remove this extension
extension UIControl.State: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
