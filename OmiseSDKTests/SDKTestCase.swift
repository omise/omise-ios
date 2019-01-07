import Foundation
import XCTest

extension XCTestCase {
    @objc static func fixturesData(forFilename filename: String) -> Data {
        let bundle = Bundle(for: ClientTestCase.self)
        let path = bundle.url(forResource: "Fixtures/objects/\(filename)", withExtension: "json")!
        let data = try! Data(contentsOf: path)
        
        return data
    }
    
    static let jsonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")!
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    static func dateFromJSONString(_ dateString: String) -> Date? {
        return jsonDateFormatter.date(from: dateString)
    }
}
