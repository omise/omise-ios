import Foundation
import XCTest
@testable import OmiseSDK

class SourcePaymentPayloadTest: XCTestCase {
    func testJSONEncoding() throws {
        let sourcePayload = SourcePaymentPayload(amount: 1, currency: "THB", details: .other(.alipay))

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(sourcePayload)
        let result = String(data: data, encoding: .utf8)
        let expectedResult = "{\"amount\":1,\"currency\":\"THB\",\"platform_type\":\"IOS\",\"type\":\"alipay\"}"
        XCTAssertEqual(result, expectedResult)
    }
}
