import XCTest
@testable import OmiseSDK

final class ThreeDSRepositoryTests: XCTestCase {

    func test_performAuthenticationSuccess() {
        let authJSON = """
        {
          "status": "success"
        }
        """
        let authData = Data(authJSON.utf8)

        let protocolClass = StubURLProtocol.self
        StubURLProtocol.requestHandler = { _ in
            guard let url = URL(string: "https://example.com") else {
                throw DummyError.defaultError
            }
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil) ?? HTTPURLResponse()
            return (response, authData)
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [protocolClass]
        let session = URLSession(configuration: config)

        let repository = ThreeDSRepository(network: NetworkService(), urlSession: session)
        let expectation = expectation(description: "auth")
        guard let authURL = URL(string: "https://example.com/auth") else {
            XCTFail("Invalid URL")
            return
        }

        repository.performAuthentication(authURL: authURL,
                                         request: makeRequest()) { result in
            if case .success(let response) = result,
               case .success = response.status {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_performAuthenticationFailure() {
        StubURLProtocol.requestHandler = { _ in
            guard let url = URL(string: "https://example.com") else {
                throw DummyError.defaultError
            }
            let response = HTTPURLResponse(url: url,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil) ?? HTTPURLResponse()
            return (response, Data())
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: config)

        let repository = ThreeDSRepository(network: NetworkService(), urlSession: session)
        let expectation = expectation(description: "auth")
        guard let authURL = URL(string: "https://example.com/auth") else {
            XCTFail("Invalid URL")
            return
        }

        repository.performAuthentication(authURL: authURL,
                                         request: makeRequest()) { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_performAuthenticationFailsOnNonSuccessStatusCode() {
        let responseJSON = """
        {
          "status": "success"
        }
        """
        let responseData = Data(responseJSON.utf8)
        
        StubURLProtocol.requestHandler = { _ in
            guard let url = URL(string: "https://example.com") else {
                throw DummyError.defaultError
            }
            let response = HTTPURLResponse(url: url,
                                           statusCode: 400,
                                           httpVersion: nil,
                                           headerFields: nil) ?? HTTPURLResponse()
            return (response, responseData)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let repository = ThreeDSRepository(network: NetworkService(), urlSession: session)
        let expectation = expectation(description: "auth")
        guard let authURL = URL(string: "https://example.com/auth") else {
            XCTFail("Invalid URL")
            return
        }
        
        repository.performAuthentication(authURL: authURL,
                                         request: makeRequest()) { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}

private func makeRequest() -> ThreeDSAuthenticationRequest {
    ThreeDSAuthenticationRequest(
        sdkTransactionId: "trans",
        sdkAppId: "app",
        sdkEphemeralPublicKey: "{}",
        maxTimeout: 5,
        encryptedDeviceInfo: "device"
    )
}

final class StubURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = StubURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "no handler", code: 0))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private enum DummyError: Error {
    case defaultError
}

// MARK: - Mapping tests

extension ThreeDSRepositoryTests {
    func test_mapUnknownStatusPreservesServerStatus() {
        let repository = ThreeDSRepository()
        let authResponse = AuthResponse(serverStatus: "custom_status", ares: nil)
        let mapped = repository.map(authResponse)
        
        if case .unknown(let status) = mapped.status {
            XCTAssertEqual(status, "custom_status")
        } else {
            XCTFail("Expected unknown status")
        }
    }
    
    func test_mapChallengeWithoutAresUsesMissingMarker() {
        let repository = ThreeDSRepository()
        let authResponse = AuthResponse(serverStatus: "challenge", ares: nil)
        let mapped = repository.map(authResponse)
        
        if case .unknown(let status) = mapped.status {
            XCTAssertEqual(status, "challenge_missing_ares")
        } else {
            XCTFail("Expected missing ares unknown status")
        }
    }
}
