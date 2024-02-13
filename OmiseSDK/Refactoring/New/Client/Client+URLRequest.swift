import Foundation
import UIKit.UIDevice

// TODO: Make it private and move test code to another test of public method
extension Client {
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
            contentType: api.contentType.rawValue
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = api.method.rawValue
        urlRequest.httpBody = api.httpBody
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }
}

// MARK: User Agent
// TODO: Make it private and move test code to another test of public method
extension Client {
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
extension Client {
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
