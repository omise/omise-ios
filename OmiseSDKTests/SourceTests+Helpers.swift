import Foundation
import XCTest
@testable import OmiseSDK

// MARK: Encode/Decode sample data from JSON mock-ups
extension SourceTests {
    /// Load JSON sample data from resources by given SourceType
    func sourceFromSampleJSONFileBy(type: SourceType) throws -> Source {
        do {
            let sourceData = try sampleData.jsonData(for: .source(sourceType: type))
            let source = try jsonDecoder.decode(Source.self, from: sourceData)
            return source
        } catch {
            XCTFail("Cannot decode the source \(error)")
            throw error
        }
    }

    /// Decode JSON string into Source.Payload
    func parsePayload(jsonString: String) throws -> Source.Payload {
        guard let data = jsonString.data(using: .utf8) else {
            struct JsonToDataCastError: Error {}
            throw JsonToDataCastError()
        }

        return try jsonDecoder.decode(Source.Payload.self, from: data)
    }
}
