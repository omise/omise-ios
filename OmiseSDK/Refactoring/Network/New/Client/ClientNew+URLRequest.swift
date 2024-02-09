import Foundation
import UIKit.UIDevice

// MARK: URLRequest
extension URLRequest {
    /// Convenient method to set HTTP headers
    /// - Parameter headers: [HTTPHeader: Value]
    mutating func setHTTPHeaders(_ headers: [String: String]) {
        for (key, value) in headers {
            self.setValue(value, forHTTPHeaderField: key)
        }
    }
}

// TODO: Make it private and move test code to another test of public method
extension ClientNew {
    func customURL(api: APIProtocol) -> URL? {
        switch api.server {
        case .api:
            return Configuration.default.environment.customAPIURL
        case .vault:
            return Configuration.default.environment.customVaultURL
        }
    }

    func url(api: APIProtocol) -> URL {
        customURL(api: api) ?? api.server.url
    }

    func urlRequest(publicKey: String, api: APIProtocol)
    -> URLRequest {
        let url = url(api: api).appendingPathComponent(api.path)
        let headers = httpHeaders(
            publicKey: publicKey,
            userAgent: userAgent(),
            apiVersion: api.omiseAPIVersion,
            contentType: api.contentType
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = api.method
        urlRequest.setHTTPHeaders(headers)

        return urlRequest
    }
}

// MARK: User Agent
// TODO: Make it private and move test code to another test of public method
extension ClientNew {
    func userAgent(
        sdkVersion: String = OmiseSDK.shared.version,
        platform: String = ProcessInfo.processInfo.operatingSystemVersionString,
        device: String = UIDevice.current.model
    ) -> String {
        "OmiseIOS/\(sdkVersion) iOS/\(platform) Apple/\(device)"
    }
}

// MARK: HTTP Headers
// TODO: Make it private and move test code to another test of public method
extension ClientNew {
    enum HTTPHeaders: String {
        case authorization = "Authorization"
        case userAgent = "User-Agent"
        case contentType = "Content-Type"
        case omiseVersion = "Omise-Version"
    }

    func httpHeaders(
        publicKey: String,
        userAgent: String,
        apiVersion: String,
        contentType: String
    ) -> [String: String] {
        [
            HTTPHeaders.authorization.rawValue: encodeAuthorizationHTTPHeader(publicKey),
            HTTPHeaders.userAgent.rawValue: userAgent,
            HTTPHeaders.contentType.rawValue: contentType,
            HTTPHeaders.omiseVersion.rawValue: apiVersion
        ]
    }

    func encodeAuthorizationHTTPHeader(_ publicKey: String) -> String {
        guard let data = publicKey.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            return ""
        }
        let base64 = data.base64EncodedString()
        return "Basic \(base64)"
    }
}
