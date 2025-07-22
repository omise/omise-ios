import XCTest
import UIKit
@testable import OmiseSDK

/// iOS 13+ specific api
@available(iOS 13.0, *)
final class ViewControllerExtensionsTests: XCTestCase {
    // MARK: - NavBarStyle
    func testApplyNavigationBarStyleNormal_clearsShadow() {
        let vc = UIViewController()
        vc.applyNavigationBarStyle(.normal)
        
        guard let appearance = vc.navigationItem.standardAppearance else {
            return XCTFail("standardAppearance should be set")
        }
        XCTAssertNil(appearance.shadowColor)
        XCTAssertNil(appearance.shadowImage)
        
        let titleColor = appearance.titleTextAttributes[.foregroundColor] as? UIColor
        XCTAssertEqual(titleColor, UIColor.headings)
        let largeTitleColor = appearance.largeTitleTextAttributes[.foregroundColor] as? UIColor
        XCTAssertEqual(largeTitleColor, UIColor.headings)
    }
    
    func testApplyNavigationBarStyleShadow_setsShadowColorAndImage() {
        let vc = UIViewController()
        let testColor = UIColor.red
        vc.applyNavigationBarStyle(.shadow(color: testColor))
        
        guard let appearance = vc.navigationItem.standardAppearance else {
            return XCTFail("standardAppearance should be set")
        }
        XCTAssertEqual(appearance.shadowColor, testColor)
        
        guard let shadowImage = appearance.shadowImage else {
            return XCTFail("shadowImage should be set for .shadow style")
        }
        XCTAssertEqual(shadowImage.renderingMode, .alwaysTemplate)
        XCTAssertEqual(shadowImage.size, CGSize(width: 1, height: 1))
    }
}
