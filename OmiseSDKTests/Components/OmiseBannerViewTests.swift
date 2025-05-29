import XCTest
@testable import OmiseSDK
import UIKit

final class OmiseBannerViewTests: XCTestCase {
    var sut: OmiseBannerView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = OmiseBannerView()
        titleLabel = try XCTUnwrap(
            sut.view(withAccessibilityIdentifier: "OmiseBannerView.titleLabel") as? UILabel
        )
        subtitleLabel = try XCTUnwrap(
            sut.view(withAccessibilityIdentifier: "OmiseBannerView.subtitleLabel") as? UILabel
        )
    }
    
    override func tearDown() {
        sut = nil
        titleLabel = nil
        subtitleLabel = nil
        super.tearDown()
    }
    
    func testConvenienceInit_setsEmptyTitleAndSubtitle() {
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.subtitle, "")
        
        XCTAssertNil(titleLabel.text)
        XCTAssertNil(subtitleLabel.text)
    }
    
    func testSettingTitle_updatesTitleLabel() {
        let newTitle = "Network error"
        sut.title = newTitle
        
        XCTAssertEqual(titleLabel.text, newTitle)
    }
    
    func testSettingSubtitle_updatesDetailLabel() {
        let newSubtitle = "Please check your connection"
        
        sut.subtitle = newSubtitle
        XCTAssertEqual(subtitleLabel.text, newSubtitle)
    }
    
    func testCloseButton_invokesOnClose() throws {
        var didClose = false
        sut.onClose = { didClose = true }
        
        sut.closeTapped()
        XCTAssertTrue(didClose)
    }
}
