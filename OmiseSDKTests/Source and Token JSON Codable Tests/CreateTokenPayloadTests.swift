import Foundation
import XCTest
@testable import OmiseSDK

class CreateTokenPayloadTests: XCTestCase {
    func testJSONEncodingDecoding() throws {
        let sourcePayload = CreateTokenPayload.Card(
            name: "John Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2020,
            securityCode: "123",
            phoneNumber: "0123456789",
            countryCode: "gb",
            city: "Bangkok",
            state: "Bangkok Metropolis",
            street1: "Sukhumvit",
            street2: "MBK",
            postalCode: "10240"
        )

        let samplePayload: CreateTokenPayload.Card = try sampleFromJSONBy(.card)
        XCTAssertEqual(samplePayload, sourcePayload)
        let jsonString = try encodeToJson(samplePayload)

        let decoded: CreateTokenPayload.Card = try parse(jsonString: jsonString)
        XCTAssertEqual(samplePayload, decoded)
    }
}
