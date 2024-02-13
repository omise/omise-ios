import Foundation
import XCTest
@testable import OmiseSDK

class SourcePaymentPayloadTest: XCTestCase {
    func testJSONEncoding() throws {
        let sourcePayload = SourcePaymentPayload(amount: 1, currency: "THB", details: .other(.alipay))

        let jsonString = try encodeToJson(sourcePayload)
        let decoded: SourcePaymentPayload = try parse(jsonString: jsonString)
        XCTAssertEqual(sourcePayload, decoded)
        let expectedJsonString = "{\"amount\":1,\"currency\":\"THB\",\"platform_type\":\"IOS\",\"type\":\"alipay\"}"
        XCTAssertEqual(jsonString, expectedJsonString)
    }
}
