import Foundation

enum DeviceDataResult<String, Failure> where Failure: Error {
  case success(String)
  case failure(Failure)
}
