import Foundation
import XCTest
import OmiseSDK

class SampleData {
    enum Entity {
        case source(type: SourceType)
        case card
        case token
        case capability
        
        var path: String {
            switch self {
            case .source(let type):
                return "sources/\(type.rawValue)"
            case .card:
                return "card"
            case .token:
                return "token"
            case .capability:
                return "capability"
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

private let sampleData = SampleData()
private let jsonDecoder = JSONDecoder()

/// Load JSON sample data from resources by given SourceType
func sampleFromJSONBy<T: Decodable>(_ entity: SampleData.Entity) throws -> T {
    do {
        switch entity {
        case .card:
            print("aa")
        default:
            break
        }
        let data = try sampleData.jsonData(for: entity)
        let obj = try jsonDecoder.decode(T.self, from: data)
        return obj
    } catch {
        XCTFail("Cannot decode \(T.self): \(entity) \(error)")
        throw error
    }
}

struct StringToDataCastError: Error {}
struct DataToStringCastError: Error {}

func encodeToJson<T: Encodable>(_ object: T) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]

    let data = try encoder.encode(object)
    guard let result = String(data: data, encoding: .utf8) else {
        throw DataToStringCastError()
    }

    return result
}
/// Decode JSON string into Decodable
func parse<T: Decodable>(jsonString: String) throws -> T {
    guard let data = jsonString.data(using: .utf8) else {
        throw StringToDataCastError()
    }

    return try jsonDecoder.decode(T.self, from: data)
}
