import Foundation
import XCTest
@testable import OmiseSDK

class OmiseSDKTests: XCTestCase {
    func testCountry() {
        let expectedCountry = Country(name: "Thailand", code: "TH")
        let capability = Capability(countryCode: "TH", paymentMethods: [], banks: Set<String>())
        OmiseSDK.shared.client.setLatestLoadedCapability(capability)

        XCTAssertEqual(expectedCountry, OmiseSDK.shared.country)
    }
}
