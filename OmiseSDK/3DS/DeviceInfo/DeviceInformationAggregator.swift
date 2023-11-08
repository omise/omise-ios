import Foundation

struct DeviceInformationAggregator {
    private let dataVersion: String = "1.4"
    private let deviceDataCollector: DeviceDataCollector
    private let warnings: [Warning]
    
    init(deviceDataCollector: DeviceDataCollector, warnings: [Warning]) {
        self.deviceDataCollector = deviceDataCollector
        self.warnings = warnings
    }
    
    func collectDeviceInformation() -> DeviceInformation {
        let deviceData = deviceDataCollector.perform()
        let availableDeviceData = deviceData.filter({ $0.isSuccess })
        let unavailableDeviceData = deviceData.filter({ !$0.isSuccess })
        
        return DeviceInformation(dataVersion: dataVersion,
                                 availableDeviceData: availableDeviceData,
                                 unavailableDeviceData: unavailableDeviceData,
                                 warnings: warnings)
    }
}
