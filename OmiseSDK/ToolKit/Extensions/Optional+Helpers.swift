import Foundation

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped == Any {
    func decode<T: Decodable>(to type: T.Type = T.self) -> T? {
        // Safely unwrap the value and decode it if possible
        guard let value = self else { return nil }
        
        // Check if the value is a dictionary or any other decodable structure
        if let jsonDict = value as? [String: Any] {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
                return nil
            }
            return try? JSONDecoder().decode(T.self, from: jsonData)
        }
        
        return nil
    }
}
