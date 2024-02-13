import Foundation
import XCTest
@testable import OmiseSDK

class SourceFlowTests: XCTestCase {
    func testDefaultValue() throws {
        let testCases: [String: Source.Flow] = [
            "\"redirect\"": .redirect,
            "\"offline\"": .offline,
            "\"app_redirect\"": .appRedirect,
            "\"unknown\"": .unknown,
            "\"Not supported flow\"": .unknown
        ]
        for (json, expectedResult) in testCases {
            XCTAssertEqual(expectedResult, try json.fromJson(Source.Flow.self))
        }
    }
}
