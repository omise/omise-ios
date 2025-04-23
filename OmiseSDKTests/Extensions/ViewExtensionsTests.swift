import XCTest
import UIKit
@testable import OmiseSDK

final class ViewExtensionsTests: XCTestCase {
    
}

/// iOS 13+ specific api
@available(iOS 13.0, *)
extension ViewExtensionsTests {
    // MARK: - Omise Color
    func testOmiseBackground_lightMode_returnsLightBackgroundColor() {
        let lightTrait = UITraitCollection(userInterfaceStyle: .light)
        let resolved = UIColor.omiseBackground.resolvedColor(with: lightTrait)
        let expected = UIColor(UIColor.Omise.lightBackground.rawValue)
        XCTAssertEqual(resolved, expected)
    }
    
    func testOmiseBackground_darkMode_returnsDarkBackgroundColor() {
        let darkTrait = UITraitCollection(userInterfaceStyle: .dark)
        let resolved = UIColor.omiseBackground.resolvedColor(with: darkTrait)
        let expected = UIColor(UIColor.Omise.darkBackground.rawValue)
        XCTAssertEqual(resolved, expected)
    }
    
    func testOmisePrimary_lightMode_returnsPrimaryColor() {
        let lightTrait = UITraitCollection(userInterfaceStyle: .light)
        let resolved = UIColor.omisePrimary.resolvedColor(with: lightTrait)
        let expected = UIColor(UIColor.Omise.primary.rawValue)
        XCTAssertEqual(resolved, expected)
    }
    
    func testOmisePrimary_darkMode_returnsSecondaryColor() {
        let darkTrait = UITraitCollection(userInterfaceStyle: .dark)
        let resolved = UIColor.omisePrimary.resolvedColor(with: darkTrait)
        let expected = UIColor(UIColor.Omise.secondary.rawValue)
        XCTAssertEqual(resolved, expected)
    }
    
    func testOmiseSecondary_lightMode_returnsSecondaryColor() {
        let lightTrait = UITraitCollection(userInterfaceStyle: .light)
        let resolved = UIColor.omiseSecondary.resolvedColor(with: lightTrait)
        let expected = UIColor(UIColor.Omise.secondary.rawValue)
        XCTAssertEqual(resolved, expected)
    }
    
    func testOmiseSecondary_darkMode_returnsPrimaryColor() {
        let darkTrait = UITraitCollection(userInterfaceStyle: .dark)
        let resolved = UIColor.omiseSecondary.resolvedColor(with: darkTrait)
        let expected = UIColor(UIColor.Omise.primary.rawValue)
        XCTAssertEqual(resolved, expected)
    }
}
