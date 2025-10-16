import XCTest
import UIKit
@testable import OmiseSDK

final class ViewControllerExtensionsTests: XCTestCase {
    // MARK: - ViewAttachable
    func testAttach_addsViewContainerOnViewWithObject() {
        let parentView = UIView()
        class Dummy: ViewAttachable { }
        let dummy = Dummy()
        parentView.attach(dummy)
        
        guard let container = parentView.subviews.first as? ViewContainer else {
            return XCTFail("Expected a ViewContainer subview")
        }
        XCTAssertIdentical(container.object as AnyObject, dummy as AnyObject)
        XCTAssertEqual(container.backgroundColor, .clear)
        XCTAssertFalse(container.isUserInteractionEnabled)
    }
    
    func testAttach_addsViewContainerOnVCWithObject() {
        let vc = UIViewController()
        vc.loadViewIfNeeded()
        class Dummy: ViewAttachable { }
        let dummy = Dummy()
        vc.attach(dummy)
        
        guard let container = vc.view.subviews.first as? ViewContainer else {
            return XCTFail("Expected a ViewContainer subview in view controller's view")
        }
        XCTAssertIdentical(container.object as AnyObject, dummy as AnyObject)
        XCTAssertEqual(container.backgroundColor, .clear)
        XCTAssertFalse(container.isUserInteractionEnabled)
    }
    
    func testMultipleAttach_createsSeparateContainers() {
        let parentView = UIView()
        class DummyA: ViewAttachable { }
        class DummyB: ViewAttachable { }
        let a = DummyA(), b = DummyB()
        
        parentView.attach(a)
        parentView.attach(b)
        
        XCTAssertEqual(parentView.subviews.count, 2)
        let containers = parentView.subviews.compactMap { $0 as? ViewContainer }
        XCTAssertEqual(containers.count, 2)
        XCTAssertIdentical(containers[0].object as AnyObject, a as AnyObject)
        XCTAssertIdentical(containers[1].object as AnyObject, b as AnyObject)
    }
    
    // MARK: - BarButton
    func testPlainUIBarButtonItem() {
        let item = UIBarButtonItem.empty
        XCTAssertEqual(item.style, .plain)
        XCTAssertEqual(item.title, "")
    }
    
    // MARK: - UITableViewCell
    func testStartAccessoryActivityIndicator() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.isUserInteractionEnabled = true
        
        cell.startAccessoryActivityIndicator()
        
        guard let indicator = cell.accessoryView as? UIActivityIndicatorView else {
            return XCTFail("accessoryView should be a UIActivityIndicatorView")
        }
        XCTAssertTrue(indicator.isAnimating)
        XCTAssertEqual(indicator.style, .medium)
        XCTAssertEqual(indicator.color.hexString, UIColor.omiseSecondary.hexString)
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }
    
    func testStopAccessoryActivityIndicator() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let dummyView = UIView()
        cell.accessoryView = dummyView
        cell.isUserInteractionEnabled = true
        
        cell.stopAccessoryActivityIndicator(nil)
        
        XCTAssertNil(cell.accessoryView)
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }
    
    func testStopAccessoryActivityIndicator_withCustomView() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.startAccessoryActivityIndicator()
        let customView = UIImageView()
        
        cell.stopAccessoryActivityIndicator(customView)
        
        guard let restored = cell.accessoryView as? UIImageView else {
            return XCTFail("accessoryView should be restored to the custom view")
        }
        XCTAssertIdentical(restored, customView)
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }
}

/// iOS 13+ specific api
@available(iOS 13.0, *)
extension ViewControllerExtensionsTests {
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
