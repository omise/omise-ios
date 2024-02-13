import Foundation
import XCTest
@testable import OmiseSDK

class OmiseSDKTests: XCTestCase {
    func testCountry() {
        let expectedCountry = Country(name: "Thailand", code: "TH")
        OmiseSDK.shared.setCurrentCountry(countryCode: "TH")
        XCTAssertEqual(expectedCountry, OmiseSDK.shared.currentCountry)
    }
}
