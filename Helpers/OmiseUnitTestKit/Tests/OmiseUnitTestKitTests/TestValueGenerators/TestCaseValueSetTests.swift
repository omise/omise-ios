import XCTest
@testable import OmiseUnitTestKit

class TestCaseValueSetTests: XCTestCase {
    func testCaseValueSet() {
        let nameSet = OmiseUnitTestKit.TestCaseValueSet<String>([
            .invalid("bb", "Name should contain 3 or more characters"),
            .invalid("Andr3y", "No digits allowed"),
            .invalid("@ndrey", "Only some special characters allowed"),
            .valid("Andrey"),
            .valid("Spider-Man")
        ])

        XCTAssertTrue(["Andrey", "Spider-Man"].contains(nameSet.valid))
        XCTAssertEqual(["Andrey", "Spider-Man"], nameSet.validAll.sorted())
        XCTAssertTrue(["bb", "Andr3y", "@ndrey"].contains(nameSet.invalid))
        XCTAssertEqual(["@ndrey", "Andr3y", "bb"], nameSet.invalidAll.sorted())
    }
}
