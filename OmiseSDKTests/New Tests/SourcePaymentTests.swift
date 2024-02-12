import Foundation
import XCTest
@testable import OmiseSDK

class SourcePaymentPayloadTest: XCTestCase {
    func testJSONEncoding() {
        let sourcePayload = SourcePayment(amount: 1, currency: "THB", details: .other(.alipay))

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try? encoder.encode(sourcePayload)
        let result = data == nil ? "" : String(data: data!, encoding: .utf8)

        let expectedResult =
        "{\"amount\":1,\"currency\":\"THB\",\"platform_type\":\"IOS\",\"type\":\"alipay\"}"

        print(result)
        print(expectedResult)
        XCTAssertEqual(result, expectedResult)
    }
}
