import Foundation
import CoreLocation

class LocationDataCollector: NSObject, DeviceDataCollector, CLLocationManagerDelegate {
  var location: CLLocation?

  let locationManager: CLLocationManager
  let semaphor = DispatchSemaphore(value: 0)
  
  init(locationManager: CLLocationManager) {
    self.locationManager = locationManager
  }
  
  func perform() -> [DeviceData] {
    guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
      CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
        return [
          GeneralDeviceData(name: "Latitude", dataIdentifier: "C011", value: .permissionRequired),
          GeneralDeviceData(name: "Longitude", dataIdentifier: "C012", value: .permissionRequired)
        ]
    }
    
    if let location = locationManager.location {
      return [
        GeneralDeviceData(name: "Latitude", dataIdentifier: "C011", value: "\(location.coordinate.latitude)"),
        GeneralDeviceData(name: "Longitude", dataIdentifier: "C012", value: "\(location.coordinate.longitude)")
      ]
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.activityType = .other
    
    locationManager.delegate = self
    if #available(iOS 9.0, *) {
      locationManager.requestLocation()
    } else {
      locationManager.startUpdatingHeading()
    }
    
    _ = semaphor.wait(timeout: .now() + 10.0)
    
    if let location = location {
      return [
        GeneralDeviceData(name: "Latitude", dataIdentifier: "C011", value: "\(location.coordinate.latitude)"),
        GeneralDeviceData(name: "Longitude", dataIdentifier: "C012", value: "\(location.coordinate.longitude)")
      ]
    } else {
      return [
        GeneralDeviceData(name: "Latitude", dataIdentifier: "C011", value: .permissionRequired),
        GeneralDeviceData(name: "Longitude", dataIdentifier: "C012", value: .permissionRequired)
      ]
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    location = locations.last
    locationManager.stopUpdatingLocation()
    semaphor.signal()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    semaphor.signal()
  }
}
