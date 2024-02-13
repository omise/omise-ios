import Foundation
import XCTest
@testable import OmiseSDK

class CardPaymentPayloadTests: XCTestCase {
    func testJSONEncodingDecoding() throws {
        let sourcePayload = CardPaymentPayload(
            name: "John Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2020,
            securityCode: "123",
            countryCode: "gb",
            city: "Bangkok",
            state: "Bangkok Metropolis",
            street1: "Sukhumvit",
            street2: "MBK",
            postalCode: "10240",
            phoneNumber: "0123456789"
        )

        let samplePayload: CardPaymentPayload = try sampleFromJSONBy(.card)
        XCTAssertEqual(samplePayload, sourcePayload)
        let jsonString = try encodeToJson(samplePayload)

        let decoded: CardPaymentPayload = try parse(jsonString: jsonString)
        XCTAssertEqual(samplePayload, decoded)
    }
}
