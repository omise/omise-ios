import Foundation
import UIKit
import AdSupport
import CoreLocation

struct CommonDataCollector: CompositionalDataCollector {
  let collectors: [DeviceDataCollector]
  
  init(device: UIDevice, locale: Locale, timeZone: TimeZone, screen: UIScreen, locationManager: CLLocationManager, bundle: Bundle, sdkAppId: String, sdkVersion: String) {
    self.collectors = [
      UIDeviceDataCollector(device: device),
      DeviceModelDataCollector(),
      PlatformDataCollector(),
      LocaleDataCollector(locale: locale),
      TimeZoneDataCollector(timeZone: timeZone),
      AdvertisingIDDataCollector(),
      ScreenResolutionDataCollector(screen: screen),
      IPAddressDataCollector(),
      LocationDataCollector(locationManager: locationManager),
      PackageNameDataCollector(bundle: bundle),
      SdkAppIdDataCollector(sdkAppId: sdkAppId),
      SdkVersionDataCollector(sdkVersion: sdkVersion)
    ]
  }
  
  func perform() -> [DeviceData] {
    return collectors.flatMap({ $0.perform() }).sorted(by: { $0.dataIdentifier < $1.dataIdentifier })
  }
}

struct UIDeviceDataCollector: DeviceDataCollector {
  let device: UIDevice
  
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(name: "OS Name", dataIdentifier: "C003", value: device.systemName),
      GeneralDeviceData(name: "OS Version", dataIdentifier: "C004", value: device.systemVersion),
      GeneralDeviceData(name: "Device Name", dataIdentifier: "C009", value: device.name)
    ]
  }
}

struct PlatformDataCollector: DeviceDataCollector {
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(name: "Platform", dataIdentifier: "C001", value: "iOS")
    ]
  }
}

struct LocaleDataCollector: DeviceDataCollector {
  let locale: Locale
    
  private var localeIdentifier: String? {
    if let languageCode = locale.languageCode, let regionCode = locale.regionCode {
        return languageCode + "-" + regionCode
    } else {
        return nil
    }
  }
  
  func perform() -> [DeviceData] {
    return [
        GeneralDeviceData(name: "Locale", dataIdentifier: "C005", value: localeIdentifier)
    ]
  }
}

struct TimeZoneDataCollector: DeviceDataCollector {
  let timeZone: TimeZone
  
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(name: "Time zone", dataIdentifier: "C006",
                        value: timeZone.abbreviation() ?? timeZone.identifier)
    ]
  }
}

struct AdvertisingIDDataCollector: DeviceDataCollector {
  func perform() -> [DeviceData] {
    guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
      return [
        GeneralDeviceData(name: "Advertising ID", dataIdentifier: "C007", value: .permissionRequired)
      ]
    }
    
    return [
      GeneralDeviceData(name: "Advertising ID", dataIdentifier: "C007",
                        value: ASIdentifierManager.shared().advertisingIdentifier.uuidString)
    ]
  }
}

struct ScreenResolutionDataCollector: DeviceDataCollector {
  let screen: UIScreen
  
  func perform() -> [DeviceData] {
    return [
      GeneralDeviceData(name: "Screen Resolution", dataIdentifier: "C008",
                        value: "\(Int(screen.nativeBounds.width))x\(Int(screen.nativeBounds.height))")
    ]
  }
}

struct PackageNameDataCollector: DeviceDataCollector {
    let bundle: Bundle
    
    func perform() -> [DeviceData] {
        return [
            GeneralDeviceData(name: "Application Package Name", dataIdentifier: "C013", value: bundle.bundleIdentifier)
        ]
    }
}

struct SdkAppIdDataCollector: DeviceDataCollector {
    let sdkAppId: String
    
    func perform() -> [DeviceData] {
        return [
            GeneralDeviceData(name: "SDK App ID", dataIdentifier: "C014", value: sdkAppId)
        ]
    }
}

struct SdkVersionDataCollector: DeviceDataCollector {
    let sdkVersion: String
    
    func perform() -> [DeviceData] {
        return [
            GeneralDeviceData(name: "SDK Version", dataIdentifier: "C015", value: sdkVersion)
        ]
    }
}
