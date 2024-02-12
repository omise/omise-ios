import Foundation
import XCTest
@testable import OmiseSDK

class PaymentPayloadTests: XCTestCase {
    let decoder = JSONDecoder()

    func testAtomeParser() {
        let atomeInfo = SourcePayload.Atome(phoneNumber: "123", shippingAddress: .init(country: "aa", city: "bb", postalCode: "sdd", state: "dfg", street1: "dfg", street2: "dfg"), items: [])
        let payment = SourcePayload(amount: 1, currency: "th", sourceType: .atome, details: .atome(atomeInfo))
        if let data = try? JSONEncoder().encode(payment) {
            print(String(data: data, encoding: .utf8)!)
        }


        parse(filename: "source_duitnow_obw")
        parse(filename: "source_atome")
        parse(filename: "source_paypay")
    }

    func parse(filename: String) {
        do {
            let jsonData = try XCTestCase.fixturesData(forFilename: filename)
            let data = try decoder.decode(Source.self, from: jsonData)
            print(data)
            XCTAssertTrue(true)
        } catch {
            print(error)
            XCTFail("Parsing results with errpr")
        }
    }
}
