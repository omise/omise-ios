import XCTest
@testable import OmiseTestSDK

class TestCaseValueGeneratorTests: XCTestCase {
    struct TestUser: Equatable {
        let name: String
        let age: Int
    }

    let funcGenerateTestUser: (OmiseTestSDK.TestCaseValueGenerator) -> (TestUser) = { gen in
        TestUser(
            name: gen.cases([
                .invalid("bb", "Name should contain 3 or more characters"),
                .invalid("Andr3y", "No digits allowed"),
                .invalid("@ndrey", "Only some special characters allowed"),
                .valid("Andrey"),
                .valid("Spider-Man")
            ]),
            age: gen.cases([
                .invalid(-1, "Age should be positive value"),
                .valid(0),
                .valid(1),
                .valid(100)
            ])
        )
    }

    func testStringValue() {
        let cases = OmiseTestSDK.TestCaseValueGenerator.validCases { generator in
            let value: String = generator.cases([
                .valid("1"),
                .valid("0"),
                .invalid("3", "Value can be 1 or 0"),
                .valid("1")
            ])
            return value
        }

        XCTAssertEqual(["0", "1", "1"], cases.sorted())
    }

    func testAllValidStruct() {
        let testUsers: [TestUser] = OmiseTestSDK.TestCaseValueGenerator.validCases(funcGenerateTestUser)

        let validUsers: [TestUser] = [
            TestUser(name: "Andrey", age: 0),
            TestUser(name: "Spider-Man", age: 1),
            TestUser(name: "Andrey", age: 100)
        ]

        XCTAssertEqual(validUsers, testUsers.sorted { $0.age < $1.age })
    }

    func testInvaludStruct() {
        let testUsers: [TestUser] = OmiseTestSDK.TestCaseValueGenerator.invalidCases(funcGenerateTestUser)

        let validUsers: [TestUser] = [
            TestUser(name: "bb", age: 0),
            TestUser(name: "Andr3y", age: 1),
            TestUser(name: "@ndrey", age: 100),
            TestUser(name: "Spider-Man", age: -1)
        ]

        XCTAssertEqual(
            validUsers.sorted { $0.age < $1.age },
            testUsers.sorted { $0.age < $1.age }
        )
    }
}
