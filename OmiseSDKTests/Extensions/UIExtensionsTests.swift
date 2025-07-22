import XCTest
import UIKit
@testable import OmiseSDK

final class UIExtensionsTests: XCTestCase {
    
    // MARK: - UIColor
    func testInitRGB_validComponents_createsCorrectColor() {
        let color = UIColor(red: 128, green: 64, blue: 32)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertEqual(red, 128.0 / 255.0, accuracy: 0.001)
        XCTAssertEqual(green, 64.0 / 255.0, accuracy: 0.001)
        XCTAssertEqual(blue, 32.0 / 255.0, accuracy: 0.001)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.001)
    }
    
    func testInitHex_createsCorrectColor() {
        let hex = 0xFF3366
        let color = UIColor(hex)
        XCTAssertEqual(color.hexString, "#FF3366")
    }
    
    func testHexString_forStandardColors_returnsCorrectString() {
        XCTAssertEqual(UIColor(red: 255, green: 0, blue: 0).hexString, "#FF0000")
        XCTAssertEqual(UIColor(red: 0, green: 255, blue: 0).hexString, "#00FF00")
        XCTAssertEqual(UIColor(red: 0, green: 0, blue: 255).hexString, "#0000FF")
    }
    
    func testImage_generatesSolidColorImage() {
        let size = CGSize(width: 10, height: 20)
        let color = UIColor(red: 10, green: 20, blue: 30)
        guard let image = color.image(size: size) else {
            XCTFail("Image should not be nil")
            return
        }
        XCTAssertEqual(image.size, size)
    }
}
