import Foundation

struct DeviceInformation {
    let dataVersion: String
    let availableDeviceData: [DeviceData]
    let unavailableDeviceData: [DeviceData]
    let warnings: [Warning]
}

extension DeviceInformation {
    static func deviceInformation(sdkAppId: String, sdkVersion: String) -> String? {
        do {
            let deviceDataAggregator = DeviceDataAggregator(locale: .current, sdkAppID: sdkAppId, sdkVersion: sdkVersion)
            let deviceInformationAggregator = DeviceInformationAggregator(deviceDataCollector: deviceDataAggregator, warnings: [])
            let deviceInformation = deviceInformationAggregator.collectDeviceInformation()
            return try deviceInformation.toJSON()
        } catch {
            print(error)
            return nil
        }
    }

    /// Converting object to postable JSON
    func toJSON(_ encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}

extension DeviceInformation: Encodable {
    private enum CodingKeys: String, CodingKey {
        case dataVersion = "DV"
        case availableDeviceData = "DD"
        case unavailableDeviceData = "DPNA"
        case warnings = "SW"
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(dataVersion, forKey: .dataVersion)
        
        if !availableDeviceData.isEmpty {
            let availableEncodableData = EncodableDeviceData(deviceData: availableDeviceData)
            try container.encode(availableEncodableData, forKey: .availableDeviceData)
        }
        
        if !unavailableDeviceData.isEmpty {
            let unavailableEncodableData = EncodableDeviceData(deviceData: unavailableDeviceData)
            try container.encode(unavailableEncodableData, forKey: .unavailableDeviceData)
        }
        
        if !warnings.isEmpty {
            let warningIds: [String] = warnings.map({ $0.id })
            try container.encode(warningIds, forKey: .warnings)
        }
    }
    
}

private struct EncodableDeviceData: Encodable {
    private struct CodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    let deviceData: [DeviceData]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        for deviceData in deviceData {
            guard let codingKey = CodingKeys(stringValue: deviceData.dataIdentifier) else {
                continue
            }
            
            switch deviceData.value {
            case .success(let success):
                switch success {
                case let value as String:
                    try container.encode(value, forKey: codingKey)
                case let value as [String]:
                    try container.encode(value, forKey: codingKey)
                default:
                    let value = String(describing: success)
                    try container.encode(value, forKey: codingKey)
                }
            case .failure(let failure):
                try container.encode(failure.reasonCode, forKey: codingKey)
            }
        }
    }
    
}
