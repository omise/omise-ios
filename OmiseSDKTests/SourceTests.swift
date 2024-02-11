import Foundation
import XCTest
@testable import OmiseSDK

class SourceTests: XCTestCase {

    let sampleData = SampleData()
    let decoder = JSONDecoder()

    func testDecodeAlipayCNSource() throws {
        do {

            let sourceData = try sampleData.jsonData(for: .source(type: .alipayCN))
            let source = try decoder.decode(SourceNew.self, from: sourceData)

            XCTAssertEqual("src_test_5owftw9kjhjisssm0n2", source.id)
            XCTAssertEqual(SourceNew.Flow.appRedirect, source.flow)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual("THB", source.currency)
            XCTAssertEqual(SourcePayload.other(.alipayCN), source.paymentInformation)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
}
