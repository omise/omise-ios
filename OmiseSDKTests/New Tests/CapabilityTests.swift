import Foundation
import XCTest
@testable import OmiseSDK

class CapabilityTests: XCTestCase {
    func testParser() {
        let decoder = JSONDecoder()

        do {
            let jsonData = try XCTestCase.fixturesData(forFilename: "capability")
            let capability = try decoder.decode(CapabilityNew.self, from: jsonData)
            print(capability)
            XCTAssertTrue(true)
        } catch {
            print(error)
            XCTFail("Parsing results with errpr")
        }
    }
}
