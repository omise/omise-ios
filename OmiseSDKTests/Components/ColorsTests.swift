import XCTest
import UIKit
@testable import OmiseSDK

private extension UIColor {
    /// Safe hex-string even for monochrome colors.
    /// For test only
    var hexString: String {
        guard let comps = cgColor.components, !comps.isEmpty else { return "#000000" }
        let (r, g, b): (CGFloat, CGFloat, CGFloat) // swiftlint:disable:this large_tuple
        switch comps.count {
        case 1:
            r = comps[0]; g = comps[0]; b = comps[0]
        case 2:
            r = comps[0]; g = comps[0]; b = comps[0]
        default:
            r = comps[0]; g = comps[1]; b = comps[2]
        }
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
    @available(iOS 13.0, *)
    func resolved(_ style: UIUserInterfaceStyle) -> UIColor {
        resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }
}

@available(iOS 13.0, *)
final class UIColorExtensionsTests: XCTestCase {
    private func assertColor(
        _ dynamic: UIColor,
        light expectedLight: UIColor,
        dark expectedDark: UIColor,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(dynamic.resolved(.light).hexString, expectedLight.hexString, "light mode mismatch", file: file, line: line)
        XCTAssertEqual(dynamic.resolved(.dark).hexString, expectedDark.hexString, "dark mode mismatch", file: file, line: line)
    }
    
    func testHeadingsLineOmisePendingPlaceholderRefundSuccess() {
        assertColor(
            UIColor.headings,
            light: UIColor(red: 0.0156862745, green: 0.0274509804, blue: 0.0509803922, alpha: 1),
            dark: .white
        )
        assertColor(
            UIColor.line,
            light: UIColor(red: 0.8941176471, green: 0.9058823529, blue: 0.9294117647, alpha: 1),
            dark: UIColor(red: 0.2274509804, green: 0.2274509804, blue: 0.2352941176, alpha: 1)
        )
    }
}
