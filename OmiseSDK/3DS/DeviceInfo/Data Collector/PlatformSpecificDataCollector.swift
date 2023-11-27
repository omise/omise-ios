import Foundation
import UIKit

struct PlatformSpecificDataCollector: CompositionalDataCollector {
  let collectors: [DeviceDataCollector]
  
  init(device: UIDevice, bundle: Bundle) {
    collectors = [
      PlatformSpecificDeviceDataCollector(device: device),
      UIFontDataCollector(),
      PlatformSpecificLocaleDataCollector(),
      PlatformSpecificTimeZoneDataCollector(),
      AppStoreReceiptUrlDataCollector(bundle: bundle)
    ]
  }
}

struct PlatformSpecificDeviceDataCollector: DeviceDataCollector {
  let device: UIDevice
  
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(name: "Identifier For Vendor",
                        dataIdentifier: "I001",
                        value: device.identifierForVendor?.uuidString),
      GeneralDeviceData(name: "UserInterfaceIdiom", dataIdentifier: "I002", value: "\(device.userInterfaceIdiom.rawValue)")
    ]
  }
}

struct UIFontDataCollector: DeviceDataCollector {
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(
        name: "familyNames",
        dataIdentifier: "I003",
        value: UIFont.familyNames),
      GeneralDeviceData(
        name: "fontNamesForFamilyName",
        dataIdentifier: "I004",
        value: UIFont.fontNames(forFamilyName: UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName)),
      GeneralDeviceData(
        name: "systemFont",
        dataIdentifier: "I005",
        value: UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName),
      GeneralDeviceData(
        name: "labelFontSize",
        dataIdentifier: "I006",
        value: "\(UIFont.labelFontSize)"),
      GeneralDeviceData(
        name: "buttonFontSize",
        dataIdentifier: "I007",
        value: "\(UIFont.buttonFontSize)"),
      GeneralDeviceData(
        name: "smallSystemFontSize",
        dataIdentifier: "I008",
        value: "\(UIFont.smallSystemFontSize)"),
      GeneralDeviceData(
        name: "systemFontSize",
        dataIdentifier: "I009",
        value: "\(UIFont.systemFontSize)")
    ]
  }
}

struct PlatformSpecificLocaleDataCollector: DeviceDataCollector {
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(
        name: "systemLocale",
        dataIdentifier: "I010",
        value: Locale.current.identifier),
      GeneralDeviceData(
        name: "availableLocaleIdentifiers",
        dataIdentifier: "I011",
        value: Locale.availableIdentifiers),
      GeneralDeviceData(
        name: "preferredLanguages",
        dataIdentifier: "I012",
        value: Locale.preferredLanguages)
    ]
  }
}

struct PlatformSpecificTimeZoneDataCollector: DeviceDataCollector {
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(
        name: "defaultTimeZone",
        dataIdentifier: "I013",
        value: TimeZone.current.identifier)
    ]
  }
}

struct AppStoreReceiptUrlDataCollector: DeviceDataCollector {
    let bundle: Bundle
    
    func perform() -> [DeviceData] {
        return [
            GeneralDeviceData(
                name: "appStoreReceiptURL",
                dataIdentifier: "I014",
                value: bundle.appStoreReceiptURL?.absoluteString)
        ]
    }
}
