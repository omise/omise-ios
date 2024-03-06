import Foundation
import XCTest
@testable import OmiseSDK

class CreateSourcePayloadTests: XCTestCase {
    func testJSONEncoding() throws {
        let sourcePayload = CreateSourcePayload(amount: 1, currency: "THB", details: .sourceType(.alipay))

        let jsonString = try encodeToJson(sourcePayload)
        let decoded: CreateSourcePayload = try parse(jsonString: jsonString)
        XCTAssertEqual(sourcePayload, decoded)
        let expectedJsonString = "{\"amount\":1,\"currency\":\"THB\",\"platform_type\":\"IOS\",\"type\":\"alipay\"}"
        XCTAssertEqual(jsonString, expectedJsonString)
    }
}
