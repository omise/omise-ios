import XCTest
@testable import OmiseSDK
import Foundation

class SHA512Tests: XCTestCase {

    func testSHA512EmptyString() {
        let emptyString = ""
        let expectedHash = Data(
            [ // expected SHA-512 hash of empty string
                0xcf, 0x83, 0xe1, 0x35, 0x7e, 0xef, 0xb8, 0xbd,
                0xf1, 0x54, 0x28, 0x50, 0xd6, 0x6d, 0x80, 0x07,
                0xd6, 0x20, 0xe4, 0x05, 0x0b, 0x57, 0x15, 0xdc,
                0x83, 0xf4, 0xa9, 0x21, 0xd3, 0x6c, 0xe9, 0xce,
                0x47, 0xd0, 0xd1, 0x3c, 0x5d, 0x85, 0xf2, 0xb0,
                0xff, 0x83, 0x18, 0xd2, 0x87, 0x7e, 0xec, 0x2f,
                0x63, 0xb9, 0x31, 0xbd, 0x47, 0x41, 0x7a, 0x81,
                0xa5, 0x38, 0x32, 0x7a, 0xf9, 0x27, 0xda, 0x3e
            ]
        )
        XCTAssertEqual(emptyString.sha512, expectedHash)
    }

    func testSHA512NonEmptyString() {
        let testString = "Hello, World!"
        // swiftlint:disable:next line_length
        let expectedHexString = "374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387"

        XCTAssertEqual(testString.sha512.hexadecimalString, expectedHexString)
    }
}

extension Data {
    var hexadecimalString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
