import Foundation

public final class ThreeDSRepository: ThreeDSRepositoryProtocol {
    private let network: NetworkService
    private let urlSession: URLSession
    
    public convenience init() {
        self.init(network: NetworkService(), urlSession: .shared)
    }
    
    init(network: NetworkService, urlSession: URLSession = .shared) {
        self.network = network
        self.urlSession = urlSession
    }
    
    public func fetchConfig(authURL: URL, completion: @escaping (Result<NetceteraSDKConfig, Error>) -> Void) {
        let api = OmiseAPI.netceteraConfig(baseUrl: authURL.removeLastPathComponent)
        var urlRequest = URLRequest(url: api.url)
        urlRequest.httpMethod = api.method.rawValue
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        network.send(urlRequest: urlRequest,
                     dateFormatter: api.dateFormatter,
                     completion: completion)
    }
    
    public func performAuthentication(
        authURL: URL,
        request: ThreeDSAuthenticationRequest,
        completion: @escaping (Result<ThreeDSAuthenticationResponse, Error>) -> Void
    ) {
        let ephemKeyPayload: Any
        if let ephemData = request.sdkEphemeralPublicKey.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: ephemData) {
            ephemKeyPayload = parsed
        } else {
            ephemKeyPayload = request.sdkEphemeralPublicKey
        }
        
        let body: [String: Any] = [
            "areq": [
                "sdkAppID": request.sdkAppId,
                "sdkEphemPubKey": ephemKeyPayload,
                "sdkMaxTimeout": request.maxTimeout,
                "sdkTransID": request.sdkTransactionId
            ],
            "encrypted_device_info": request.encryptedDeviceInfo,
            "device_type": "iOS"
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(.failure(ThreeDSRepositoryError.invalidResponse))
            return
        }
        
        var urlRequest = URLRequest(url: authURL)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = bodyData
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data
            else {
                completion(.failure(ThreeDSRepositoryError.invalidResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                let mapped = self.map(authResponse)
                completion(.success(mapped))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension ThreeDSRepository {
    func map(_ response: AuthResponse) -> ThreeDSAuthenticationResponse {
        switch response.status {
        case .success:
            return ThreeDSAuthenticationResponse(status: .success)
        case .failed:
            return ThreeDSAuthenticationResponse(status: .failed)
        case .unknown:
            return ThreeDSAuthenticationResponse(status: .unknown(response.serverStatus))
        case .challenge:
            guard let ares = response.ares else {
                return ThreeDSAuthenticationResponse(status: .unknown("challenge_missing_ares"))
            }
            
            let challenge = ThreeDSChallengeData(
                threeDSServerTransactionID: ares.threeDSServerTransID,
                acsTransactionID: ares.acsTransID,
                acsSignedContent: ares.acsSignedContent,
                acsReferenceNumber: ares.acsReferenceNumber,
                sdkTransactionID: ares.sdkTransID
            )
            return ThreeDSAuthenticationResponse(status: .challenge(challenge))
        }
    }
}
