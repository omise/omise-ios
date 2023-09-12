import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

class UIButtonCustomizationTests: XCTestCase {
    let backgroundColorHex = "#FFFFFF"
    let darkBackgroundColorHex = "#000000"
    let cornerRadius: Int = 12

    let testTextFontName = "Arial-BoldItalicMT"
    let testTextColorHex = "#C4A484"
    let testDarkTextColorHex = "#964B00"
    let testTextFontSize = 14

    func testNetceteraInit() {
        let uiCustomization = UIButtonCustomization(
            backgroundColorHex: backgroundColorHex,
            darkBackgroundColorHex: darkBackgroundColorHex,
            cornerRadius: cornerRadius,
            textFontName: testTextFontName,
            textColorHex: testTextColorHex,
            darkTextColorHex: testDarkTextColorHex,
            textFontSize: testTextFontSize)

        let netCustomization: ThreeDS_SDK.ButtonCustomization
        do {
            try netCustomization = ThreeDS_SDK.ButtonCustomization(uiCustomization)
        } catch {
            XCTAssert(false, error.localizedDescription)
            return
        }

        XCTAssertEqual(netCustomization.getBackgroundColor(), backgroundColorHex)
        XCTAssertEqual(netCustomization.getCornerRadius(), cornerRadius)

        XCTAssertEqual(netCustomization.getTextFontName(), testTextFontName)
        XCTAssertEqual(netCustomization.getTextColor(), testTextColorHex)
        XCTAssertEqual(netCustomization.getTextFontSize(), testTextFontSize)
    }

    func testNetceteraCustomization() {
        let uiCustomization = UIButtonCustomization(
            backgroundColorHex: backgroundColorHex,
            darkBackgroundColorHex: darkBackgroundColorHex,
            cornerRadius: cornerRadius,
            textFontName: testTextFontName,
            textColorHex: testTextColorHex,
            darkTextColorHex: testDarkTextColorHex,
            textFontSize: testTextFontSize)

        let netCustomization = ThreeDS_SDK.ButtonCustomization()
        do {
            try netCustomization.customize(uiCustomization)
        } catch {
            XCTAssert(false, error.localizedDescription)
        }

        XCTAssertEqual(netCustomization.getBackgroundColor(), backgroundColorHex)
        XCTAssertEqual(netCustomization.getCornerRadius(), cornerRadius)
        XCTAssertEqual(netCustomization.getTextFontName(), testTextFontName)
        XCTAssertEqual(netCustomization.getTextColor(), testTextColorHex)
        XCTAssertEqual(netCustomization.getTextFontSize(), testTextFontSize)
    }
}
