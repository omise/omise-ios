import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

class UICustomizationTests: XCTestCase {
    let testTextFontName = "Arial-BoldItalicMT"
    let testTextColorHex = "#C4A484"
    let testDarkTextColorHex = "#964B00"
    let testTextFontSize = 14

    func testNetceteraCustomization() {
        let uiCustomization = UICustomization(
            textFontName: testTextFontName,
            textColorHex: testTextColorHex,
            darkTextColorHex: testDarkTextColorHex,
            textFontSize: testTextFontSize)

        let netCustomization = ThreeDS_SDK.Customization()
        do {
            try netCustomization.customize(omiseUICustomization: uiCustomization)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }

        XCTAssertEqual(netCustomization.getTextFontName(), testTextFontName)
        XCTAssertEqual(netCustomization.getTextColor(), testTextColorHex)
        XCTAssertEqual(netCustomization.getTextFontSize(), testTextFontSize)
    }
}
