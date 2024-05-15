import XCTest
@testable import OmiseSDK

private let timeout: TimeInterval = 15.0

class URLPathComponentsTests: XCTestCase {

    func testRemoveLastPathComponent() {
        let tests = [
            "https://test.com": "https://test.com/test",
            "https://test.com/endpoint": "https://test.com/test",
            "https://test.com/path/endpoint": "https://test.com/path/test",
            "https://test.com/path/endpoint?test=2": "https://test.com/path/test"
        ]

        for (urlString, expectedResult) in tests {
            guard let url = URL(string: urlString) else {
                XCTFail("Can't resolve test URL")
                return
            }

            let result = url.removeLastPathComponent
                .appendingPathComponent("test", isDirectory: false)

            XCTAssertEqual(result.absoluteString, expectedResult)
        }
    }
}
