import Foundation
import XCTest
@testable import OmiseSDK

class PaymentPayloadTests: XCTestCase {
    let decoder = JSONDecoder()

    func testAtomeParser() {

        let s = SourceNew.PaymentInformation.fpx(.init(name: "aa", val: "bb"))
        if let data = try? JSONEncoder().encode(s) {
            print(String(data: data, encoding: .utf8))
        }

        parse(filename: "source_duitnow_obw")
        parse(filename: "source_atome")
        parse(filename: "source_paypay")
    }

    func parse(filename: String) {
        do {
            let jsonData = try XCTestCase.fixturesData(forFilename: filename)
            let data = try decoder.decode(SourceNew.self, from: jsonData)
            print(data)
            XCTAssertTrue(true)
        } catch {
            print(error)
            XCTFail("Parsing results with errpr")
        }
    }
}
