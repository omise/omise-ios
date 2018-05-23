import Foundation
import XCTest

extension XCTestCase {
    static func fixturesDataFor(_ filename: String) -> Data? {
        let bundle = Bundle(for: OmiseTokenRequestTest.self)
        guard let path = bundle.url(forResource: "Fixtures/objects/\(filename)", withExtension: "json") else {
            XCTFail("could not load fixtures.")
            return nil
        }
        
        guard let data = try? Data(contentsOf: path) else {
            XCTFail("could not load fixtures at path: \(path)")
            return nil
        }
        
        return data
    }
}
