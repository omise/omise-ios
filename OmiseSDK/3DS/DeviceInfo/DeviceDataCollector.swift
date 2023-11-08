import Foundation

protocol DeviceDataCollector {
  func perform() -> [DeviceData]
}

protocol CompositionalDataCollector: DeviceDataCollector {
  var collectors: [DeviceDataCollector] { get }
}

extension CompositionalDataCollector {
  internal func perform() -> [DeviceData] {
    return collectors.flatMap({ $0.perform() }).sorted(by: { $0.dataIdentifier < $1.dataIdentifier })
  }
}
protocol DeviceData {
  var name: String { get }
  var dataIdentifier: String { get }
  var value: DeviceDataResult<Any, DataParameterUnavailability> { get }
}

extension DeviceData {
  internal var isSuccess: Bool {
    if case .success = value {
      return true
    } else {
      return false
    }
  }
}

struct GeneralDeviceData: DeviceData {
  let name: String
  let dataIdentifier: String
  let value: DeviceDataResult<Any, DataParameterUnavailability>
    
  private init(name: String, dataIdentifier: String, value: DeviceDataResult<Any, DataParameterUnavailability>) {
      self.name = name
      self.dataIdentifier = dataIdentifier
      self.value = value
  }
  
  init(name: String, dataIdentifier: String, value: String?) {
      if let value = value, !value.isEmpty {
          self.init(name: name, dataIdentifier: dataIdentifier, value: .success(value))
      } else {
          self.init(name: name, dataIdentifier: dataIdentifier, value: .failure(DataParameterUnavailability.nullOrBlankValue))
      }
  }

  init(name: String, dataIdentifier: String, value: [String]) {
      if !value.isEmpty {
          self.init(name: name, dataIdentifier: dataIdentifier, value: .success(value))
      } else {
          self.init(name: name, dataIdentifier: dataIdentifier, value: .failure(DataParameterUnavailability.nullOrBlankValue))
      }
  }

  init(name: String, dataIdentifier: String, value: DataParameterUnavailability) {
      self.init(name: name, dataIdentifier: dataIdentifier, value: .failure(value))
  }
}

enum DataParameterUnavailability: Error {
  case marketOrRegionalRestriction
  case platformVersionNotSupport
  case platformVersionDeprecated
  case permissionRequired
  case nullOrBlankValue
  
  var reasonCode: String {
    switch self {
    case .marketOrRegionalRestriction:
      return "RE01"
    case .platformVersionNotSupport, .platformVersionDeprecated:
      return "RE02"
    case .permissionRequired:
      return "RE03"
    case .nullOrBlankValue:
        return "RE04"
    }
  }
}
