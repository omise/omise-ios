import XCTest
import UIKit
@testable import OmiseSwiftUIKit

class UIKitViewPresentableTests: XCTestCase {
    func testTodo() {
        let view = UIView()
        let presentable = UIKitViewPresentable<UIView>(view: view)
        XCTAssertEqual(view, presentable.view)
    }
}
