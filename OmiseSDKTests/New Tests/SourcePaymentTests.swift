import Foundation
import XCTest
@testable import OmiseSDK

class SourcePaymentPayloadTest: XCTestCase {
    func testPaymentInformation() {
        let atomeInfo = SourcePayload.Atome(phoneNumber: "123", shippingAddress: .init(country: "aa", city: "bb", postalCode: "sdd", state: "dfg", street1: "dfg", street2: "dfg"), items: [])

        let paymentInfo = SourcePayload.atome(atomeInfo)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try? encoder.encode(paymentInfo)
        let result = data == nil ? "" : String(data: data!, encoding: .utf8)
        print(result)
        XCTAssertNotNil(result)
    }
    
    func testJSONEncoding() {
        let sourcePayload = SourcePayment(amount: 1, currency: "THB", details: .other(.alipay))

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try? encoder.encode(sourcePayload)
        let result = data == nil ? "" : String(data: data!, encoding: .utf8)

        let expectedResult: String? =
"{\"amount\":1,\"currency\":\"THB\",\"platform_type\":\"IOS\",\"type\":\"alipay\"}"
        print(result)
        print(expectedResult)
        XCTAssertEqual(result, expectedResult)
    }
}
