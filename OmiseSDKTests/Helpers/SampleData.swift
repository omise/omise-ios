import Foundation
import XCTest
import OmiseSDK

class SampleData {
    enum Entity {
        case source(type: SourceType)

        var path: String {
            switch self {
            case .source(let type):
                return "sources/\(type.rawValue)"
            }
        }
    }

    func jsonData(for entity: Entity) throws -> Data {
        let bundle = Bundle(for: Self.self)
        let path = try XCTUnwrap(
            bundle.url(forResource: "SampleData/\(entity.path)", withExtension: "json")
        )
        let data = try Data(contentsOf: path)
        return data
    }
}
