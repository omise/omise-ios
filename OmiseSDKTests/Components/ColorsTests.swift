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
    
    func testBackgroundAndAccessoryTint() {
        let sysBgL = UIColor.systemBackground.resolved(.light).hexString
        let sysBgD = UIColor.systemBackground.resolved(.dark).hexString
        XCTAssertEqual(UIColor.background.resolved(.light).hexString, sysBgL)
        XCTAssertEqual(UIColor.background.resolved(.dark).hexString, sysBgD)
        
        let secBgL = UIColor.secondarySystemBackground.resolved(.light).hexString
        let secBgD = UIColor.secondarySystemBackground.resolved(.dark).hexString
        XCTAssertEqual(UIColor.formAccessoryBarTintColor.resolved(.light).hexString, secBgL)
        XCTAssertEqual(UIColor.formAccessoryBarTintColor.resolved(.dark).hexString, secBgD)
    }
    
    func testSelectedCellBackgroundColor() {
        let light = UIColor(red: 0.968627451, green: 0.9725490196, blue: 0.9803921569, alpha: 1)
        let dark  = UIColor(red: 0.1725490196, green: 0.1725490196, blue: 0.1803921569, alpha: 1)
        assertColor(UIColor.selectedCellBackgroundColor, light: light, dark: dark)
    }
    
    func testBadgeBackgroundBaseAndElevatedResolveSame() {
        let light = UIColor.white
        let dark  = UIColor(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
        assertColor(UIColor.badgeBackground, light: light, dark: dark)
        
        // when “elevated” in dark mode, should resolve to systemGray5
        let elevatedTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .dark),
            UITraitCollection(userInterfaceLevel: .elevated)
        ])
        let resolvedElevatedHex = UIColor.badgeBackground
            .resolvedColor(with: elevatedTraits)
            .hexString
        let sysGray5Hex = UIColor.systemGray5
            .resolvedColor(with: elevatedTraits)
            .hexString
        
        XCTAssertEqual(
            resolvedElevatedHex,
            sysGray5Hex,
            "Elevated dark mode should use systemGray5"
        )
    }
    
    func testBodyAndDescription() {
        assertColor(
            UIColor.body,
            light: UIColor(red: 0.2352941176, green: 0.2549019608, blue: 0.3019607843, alpha: 1),
            dark: UIColor(red: 0.8196078431, green: 0.8196078431, blue: 0.8392156863, alpha: 1)
        )
        assertColor(
            UIColor.description,
            light: UIColor(red: 0.5215686275, green: 0.5450980392, blue: 0.6039215686, alpha: 1),
            dark: UIColor(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        )
    }
    
    func testEmptyPageAndErrorVariants() {
        assertColor(
            UIColor.emptyPage,
            light: UIColor(red: 0.6705882353, green: 0.698039217, blue: 0.7607843137, alpha: 1),
            dark: UIColor(red: 0.3882352941, green: 0.3882352941, blue: 0.4000000000, alpha: 1)
        )
        assertColor(
            UIColor.error,
            light: UIColor(red: 0.9372549020, green: 0.2078431373, blue: 0.1490196078, alpha: 1),
            dark: UIColor(red: 0.9882352941, green: 0.4431372549, blue: 0.4000000000, alpha: 1)
        )
        assertColor(
            UIColor.errorHighlighed,
            light: UIColor(red: 0.8352941176, green: 0.0784313725, blue: 0.0156862745, alpha: 1),
            dark: UIColor(red: 0.9372549020, green: 0.2078431373, blue: 0.1490196078, alpha: 1)
        )
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
        assertColor(
            UIColor.omise,
            light: UIColor(red: 0.1019607843, green: 0.3372549020, blue: 0.9411764706, alpha: 1),
            dark: UIColor(red: 0.1294117647, green: 0.4627450980, blue: 1.0000000000, alpha: 1)
        )
        assertColor(
            UIColor.omiseHighlighted,
            light: UIColor(red: 0.0588235294, green: 0.2274509804, blue: 0.6666666667, alpha: 1),
            dark: UIColor(red: 0.1019607843, green: 0.3372549020, blue: 0.9411764706, alpha: 1)
        )
        assertColor(
            UIColor.pending,
            light: UIColor(red: 1.0000000000, green: 0.7019607843, blue: 0.0000000000, alpha: 1),
            dark: UIColor(red: 1.0000000000, green: 0.7921568627, blue: 0.2980392177, alpha: 1)
        )
        assertColor(
            UIColor.placeholder,
            light: UIColor(red: 0.8156862745, green: 0.8392156863, blue: 0.8862745098, alpha: 1),
            dark: UIColor(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
        )
        assertColor(
            UIColor.refund,
            light: UIColor(red: 0.4901960784, green: 0.3333333333, blue: 0.9647058824, alpha: 1),
            dark: UIColor(red: 0.6509803922, green: 0.5411764706, blue: 0.9921568627, alpha: 1)
        )
        assertColor(
            UIColor.success,
            light: UIColor(red: 0.0549019608, green: 0.7490196078, blue: 0.6039215686, alpha: 1),
            dark: UIColor(red: 0.3960784314, green: 0.8235294118, blue: 0.7333333333, alpha: 1)
        )
    }
}
