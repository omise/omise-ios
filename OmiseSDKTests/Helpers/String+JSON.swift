import Foundation

extension String {

    struct DataFromStringError: Error {}
    struct StringFromDateError: Error {}

    /// Decode JSON object from current string
    /// - returns Generic Decodable object
    /// - throws: An error if any value throws an error during decoding
    ///
    func fromJson<T: Decodable>(_ type: T.Type) throws -> T {
        guard let data = data(using: .utf8) else {
            throw DataFromStringError()

        }

        let decoder = JSONDecoder()
        let object = try decoder.decode(T.self, from: data)
        return object
    }

    /// JSON string by encoding Encodable object
    /// - parameter codable  Encodable object
    init<T: Encodable>(_ encodable: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(encodable)
        guard let string = String(data: data, encoding: .utf8) else {
            throw StringFromDateError()
        }

        self = string
    }

}
