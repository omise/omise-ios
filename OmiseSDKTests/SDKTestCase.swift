import Foundation
import XCTest

class SDKTestCase: XCTestCase {
    func fixturesDataFor(filename: String) -> NSData? {
        let bundle = NSBundle(forClass: OmiseTokenRequestTest.self)
        guard let path = bundle.pathForResource("Fixtures/objects/\(filename)", ofType: "json") else {
            XCTFail("could not load fixtures.")
            return nil
        }
        
        guard let data = NSData(contentsOfFile: path) else {
            XCTFail("could not load fixtures at path: \(path)")
            return nil
        }
        
        return data
    }
}
