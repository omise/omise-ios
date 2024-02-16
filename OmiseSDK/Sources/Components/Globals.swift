import UIKit
import os

let sdkLogObject = OSLog(subsystem: "co.omise.ios.sdk", category: "SDK")
let uiLogObject = OSLog(subsystem: "co.omise.ios.sdk", category: "UI")

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
