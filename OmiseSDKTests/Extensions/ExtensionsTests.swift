import XCTest
@testable import OmiseSDK

final class ExtensionsTests: XCTestCase {
    
    // MARK: - String
    func testLocalized_returnsDefaultValueWhenKeyNotFound() {
        let key = "someNonexistentKey"
        let fallback = "Default Fallback"
        let result = key.localized(fallback)
        
        XCTAssertEqual(result, fallback)
    }
    
    func testLocalized_returnsKeyWhenNoDefaultValueProvidedAndKeyNotFound() {
        let key = "missingKey"
        let result = key.localized()
        
        XCTAssertEqual(result, key)
    }
    
    // MARK: - Array
    func testAt_validIndexReturnsCorrectElement() {
        let array = ["a", "b", "c"]
        XCTAssertEqual(array.at(1), "b")
    }
    
    func testAt_negativeIndexReturnsNil() {
        let array = [1, 2, 3]
        XCTAssertNil(array.at(-1))
    }
    
    func testAt_indexOutOfBoundReturnsNil() {
        let array = [true, false]
        XCTAssertNil(array.at(2))
    }
    
    func testReorder_withFullPreferredOrder_sortsExactly() {
        let array = ["a", "b", "c"]
        let preferred = ["b", "a", "c"]
        XCTAssertEqual(array.reorder(by: preferred), ["b", "a", "c"])
    }
    
    func testReorder_withPartialPreferredOrder_movesPreferredFirst() {
        let array = [1, 2, 3, 4, 5]
        let preferred = [3, 1]
        let result = array.reorder(by: preferred)
        // Preferred elements appear in order
        XCTAssertEqual(Array(result.prefix(2)), [3, 1])
        // The remaining elements are exactly the others (in any order)
        XCTAssertEqual(Set(result.suffix(from: 2)), Set([2, 4, 5]))
    }
    
    func testReorder_withEmptyPreferredOrder_returnsOriginal() {
        let array = [1, 2, 3]
        XCTAssertEqual(array.reorder(by: []), [1, 2, 3])
    }
    
    func testReorder_withEmptyArray_returnsEmpty() {
        let array: [String] = []
        XCTAssertEqual(array.reorder(by: ["x", "y"]), [])
    }
    
    // MARK: - Optional
    func testIsNilOrEmpty_withNilOptional_returnsTrue() {
        let value: String? = nil
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testIsNilOrEmpty_withEmptyString_returnsTrue() {
        let value: String? = ""
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testIsNilOrEmpty_withNonEmptyString_returnsFalse() {
        let value: String? = "Hello"
        XCTAssertFalse(value.isNilOrEmpty)
    }
    
    func testIsNilOrEmpty_withWhitespaceString_returnsFalse() {
        let value: String? = "   "
        XCTAssertFalse(value.isNilOrEmpty)
    }
    
    // MARK: - URL
    func testMatch_withExactURLString_returnsTrue() {
        guard let url = URL(string: "https://example.com/path/to/resource") else {
            XCTFail("Failed to create URL")
            return
        }
        XCTAssertTrue(url.match(string: "https://example.com/path/to/resource"))
    }
    
    func testMatch_withPrefixPath_returnsTrue() {
        guard let url = URL(string: "https://example.com/path/to/resource/details?id=123") else {
            XCTFail("Failed to create URL")
            return
        }
        XCTAssertTrue(url.match(string: "https://example.com/path/to/resource/details"))
    }
    
    func testMatch_withDifferentHost_returnsFalse() {
        guard let url = URL(string: "https://api.example.com/path") else {
            XCTFail("Failed to create URL")
            return
        }
        XCTAssertFalse(url.match(string: "https://example.com/path"))
    }
    
    func testMatch_withDifferentScheme_returnsFalse() {
        guard let url = URL(string: "http://example.com/path") else {
            XCTFail("Failed to create URL")
            return
        }
        XCTAssertFalse(url.match(string: "https://example.com/path"))
    }
    
    func testRemoveLastPathComponent_dropsLastSegmentAndQuery() {
        guard let original = URL(string: "https://example.com/a/b/c?foo=bar&baz=qux") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = original.removeLastPathComponent
        XCTAssertEqual(result.absoluteString, "https://example.com/a/b")
    }
    
    func testRemoveLastPathComponent_onRoot_returnsSameURL() {
        guard let original = URL(string: "https://example.com") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = original.removeLastPathComponent
        XCTAssertEqual(result.absoluteString, "https://example.com")
    }
    
    func testAppendingLastPathComponent_addsSegmentToExistingPath() {
        guard let base = URL(string: "https://example.com/a/b") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = base.appendingLastPathComponent("c")
        XCTAssertEqual(result.absoluteString, "https://example.com/a/b/c")
    }
    
    func testAppendingLastPathComponent_onRoot_addsLeadingSlash() {
        guard let base = URL(string: "https://example.com") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = base.appendingLastPathComponent("/home")
        XCTAssertEqual(result.absoluteString, "https://example.com/home")
    }
    
    func testAppendQueryItem_onURLWithoutQuery_addsSingleQueryItem() {
        guard let base = URL(string: "https://example.com/path") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = base.appendQueryItem(name: "key", value: "value")
        XCTAssertEqual(result?.absoluteString, "https://example.com/path?key=value")
    }
    
    func testAppendQueryItem_onURLWithExistingQuery_appendsToList() {
        guard let base = URL(string: "https://example.com/path?foo=bar") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = base.appendQueryItem(name: "baz", value: "qux")
        // order of queryItems is preserved: foo=bar then baz=qux
        XCTAssertEqual(result?.absoluteString, "https://example.com/path?foo=bar&baz=qux")
    }
    
    func testAppendQueryItem_withNilValue_encodesKeyOnly() {
        guard let base = URL(string: "https://example.com") else {
            XCTFail("Failed to create URL")
            return
        }
        let result = base.appendQueryItem(name: "empty", value: nil)
        XCTAssertEqual(result?.absoluteString, "https://example.com?empty")
    }
    
    func testURLComponentsMatch_withExactMatch_returnsTrue() {
        guard let components = URLComponents(string: "https://example.com/path/to/resource") else {
            XCTFail("Failed to create URL")
            return
        }
        XCTAssertTrue(components.match(string: "https://example.com/path/to/resource"))
    }
    
    func testURLComponentsMatch_withDifferentHost_returnsFalse() {
        guard let components = URLComponents(string: "https://api.example.com/path") else {
            XCTFail("Failed to create URL")
            return
        }
        XCTAssertFalse(components.match(string: "https://example.com/path"))
    }
}
