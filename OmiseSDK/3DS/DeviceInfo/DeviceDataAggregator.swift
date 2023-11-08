import UIKit
import CoreLocation

struct DeviceDataAggregator: DeviceDataCollector {
    
    private let collectors: [CompositionalDataCollector]
    
    init(locale: Locale, sdkAppID: String, sdkVersion: String) {
        self.collectors = [
            CommonDataCollector(device: UIDevice.current,
                                locale: locale,
                                timeZone: TimeZone.current,
                                screen: UIScreen.main,
                                locationManager: CLLocationManager(),
                                bundle: Bundle.main,
                                sdkAppId: sdkAppID,
                                sdkVersion: sdkVersion),
            PlatformSpecificDataCollector(device: UIDevice.current,
                                          bundle: Bundle.main)
        ]
    }
    
    func perform() -> [DeviceData] {
        return collectors.compactMap({ $0.perform() }).flatMap({ $0 })
    }
}
