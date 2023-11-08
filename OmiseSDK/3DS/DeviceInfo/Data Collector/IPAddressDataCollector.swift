import Foundation
import Darwin

private typealias InetFamily = UInt8
private typealias Flags = Int32

// swiftlint:disable identifier_name
struct IPAddressDataCollector: DeviceDataCollector {
  enum LocalIPError: Error {
      case failedToRetrieveInterfaces(errorCode: Int32)
      case noEn0Address
  }

  func getLocalIP() throws -> String {
      // Retrieve the current interfaces - returns 0 on success.
      var interfaces : UnsafeMutablePointer<ifaddrs>? = nil
      let errorCode = getifaddrs(&interfaces)

      defer {
          // Free memory.
          freeifaddrs(interfaces)
      }

      guard
          errorCode == 0,
          let interfaceSequence = interfaces.flatMap({ first_addr in
              sequence(
                  first: first_addr,
                  next: { addr in addr.pointee.ifa_next }
              )
          })
      else { throw LocalIPError.failedToRetrieveInterfaces(errorCode: errorCode) }

      if let address = interfaceSequence.compactMap({ (temp_addr) -> String? in
          guard
              let ifa_addr = temp_addr.pointee.ifa_addr,
              ifa_addr.pointee.sa_family == sa_family_t(AF_INET),
              // Check if interface is en0 which is the wifi connection on the iPhone.
              String(cString: (temp_addr.pointee.ifa_name)) == "en0"
          else { return nil }

          return ifa_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { sockaddr_ptr -> String? in
              guard let sin_addr = inet_ntoa(sockaddr_ptr.pointee.sin_addr) else { return nil }
              return String(cString: sin_addr)
          })
      }).last {
          return address
      } else {
          throw LocalIPError.noEn0Address
      }
  }

  func perform() -> [DeviceData] {
      let ipAddress: String? = try? getLocalIP()

      return [
          GeneralDeviceData(name: "IP Address", dataIdentifier: "C010", value: ipAddress)
      ]
  }
  
  fileprivate static func extractAddress_ipv4(_ address: UnsafeMutablePointer<sockaddr_storage>) -> String? {
    return address.withMemoryRebound(to: sockaddr.self, capacity: 1) { addr in
      var address: String?
      var hostname = [CChar](repeating: 0, count: Int(2049))
      if getnameinfo(&addr.pointee, socklen_t(socklen_t(addr.pointee.sa_len)), &hostname,
                      socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
        address = String(cString: hostname)
      } else {
        //            var error = String.fromCString(gai_strerror(errno))!
        //            println("ERROR: \(error)")
      }
      return address
      
    }
  }

  fileprivate static func extractAddress_ipv6(_ address: UnsafeMutablePointer<sockaddr_storage>) -> String? {
    var addr = address.pointee
    var ip: [Int8] = [Int8](repeating: Int8(0), count: Int(INET6_ADDRSTRLEN))
    return inetNtoP(&addr, ip: &ip)
  }
  
  fileprivate static func inetNtoP(_ addr: UnsafeMutablePointer<sockaddr_storage>, ip: UnsafeMutablePointer<Int8>) -> String? {
    return addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { addr6 in
      let conversion: UnsafePointer<CChar> = inet_ntop(AF_INET6, &addr6.pointee.sin6_addr, ip, socklen_t(INET6_ADDRSTRLEN))
      return String(cString: conversion)
    }
  }

}
// swiftlint:enable identifier_name
