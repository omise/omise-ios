import Foundation
import os


@available(iOS 10.0, *)
let sdkLogObject: OSLog = OSLog(subsystem: "co.omise.ios.sdk", category: "SDK")

@available(iOS 10.0, *)
let uiLogObject: OSLog = OSLog(subsystem: "co.omise.ios.sdk", category: "UI")


extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}


private struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.init(key: stringValue)
    }
    
    init(key: String) {
        self.stringValue = key
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension Decoder {
    func decodeJSONDictionary() throws -> Dictionary<String, Any> {
        let container = try self.container(keyedBy: JSONCodingKeys.self)
        return try container.decodeJSONDictionary()
    }
}

extension KeyedDecodingContainerProtocol {
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: Key) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decodeJSONDictionary()
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: Key) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: Key) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decodeJSONArray()
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: Key) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decodeJSONDictionary() throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            } else if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = String?.none as Any
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decodeJSONArray() throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decodeArrayElement() {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    private mutating func decodeArrayElement() throws -> Array<Any> {
        var nestedContainer = try self.nestedUnkeyedContainer()
        return try nestedContainer.decodeJSONArray()
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decodeJSONDictionary()
    }
}


extension Encoder {
    func encodeJSONDictionary(_ jsonDictionary: Dictionary<String, Any>) throws {
        var container = self.container(keyedBy: JSONCodingKeys.self)
        try container.encodeJSONDictionary(jsonDictionary)
    }
}

extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    mutating func encodeJSONDictionary(_ value: Dictionary<String, Any>) throws {
        try value.forEach({ (key, value) in
            let key = JSONCodingKeys(key: key)
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as Dictionary<String, Any>:
                try encode(value, forKey: key)
            case let value as Array<Any>:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        })
    }
}

extension KeyedEncodingContainerProtocol {
    mutating func encode(_ value: Dictionary<String, Any>, forKey key: Key) throws {
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encodeJSONDictionary(value)
    }
    
    mutating func encodeIfPresent(_ value: Dictionary<String, Any>?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
    
    mutating func encode(_ value: Array<Any>, forKey key: Key) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encodeJSONArray(value)
    }
    
    mutating func encodeIfPresent(_ value: Array<Any>?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
}

extension UnkeyedEncodingContainer {
    mutating func encodeJSONArray(_ value: Array<Any>) throws {
        try value.enumerated().forEach({ (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as Dictionary<String, Any>:
                try encodeJSONDictionary(value)
            case let value as Array<Any>:
                try encodeArrayElement(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        })
    }
    
    private mutating func encodeArrayElement(_ value: Array<Any>) throws {
        var nestedContainer = self.nestedUnkeyedContainer()
        try nestedContainer.encodeJSONArray(value)
    }
    
    mutating func encodeJSONDictionary(_ value: Dictionary<String, Any>) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encodeJSONDictionary(value)
    }
}

extension ControlState: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension Bundle {
    public static let omiseSDKBundle = Bundle(for: CreditCardFormViewController.self)
}

extension NumberFormatter {
    static func makeAmountFormatter(for currency: Currency?) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency?.code
        if currency == .thb {
            formatter.currencySymbol = "฿"
        }
        return formatter
    }
}

