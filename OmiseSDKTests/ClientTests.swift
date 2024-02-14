import Foundation
import XCTest
@testable import OmiseSDK

struct NetworkMockup: NetworkServiceProtocol {
    var sendClosure: (URLRequest) -> Void = { _ in }

    func send<T: Decodable>(
        urlRequest: URLRequest,
        dateFormatter: DateFormatter?,
        completion: @escaping RequestResultClosure<T, Error>
    ) {
        self.sendClosure(urlRequest)
    }
}

class ClientTests: XCTestCase {
    let publicKey = "pkey_test_58wfnlwoxz1tbkdd993"
    let publicKeyBase64 = "cGtleV90ZXN0XzU4d2ZubHdveHoxdGJrZGQ5OTM="
    let requestTimeout: TimeInterval = 15.0

    var testClient: Client!

    override func setUp() {
        super.setUp()
        testClient = Client(publicKey: publicKey)
        
        // swiftlint:disable force_unwrapping
        let testEnvironment = Environment.dev(
            vaultURL: URL(string: "https://vault.staging-omise.co")!,
            apiURL: URL(string: "https://api.staging-omise.co")!
        )
        // swiftlint:enable force_unwrapping
        Configuration.setShared(Configuration(environment: testEnvironment))
    }

    override func tearDown() {
        testClient = nil
        super.tearDown()
    }
    let tokenPayload = CreateTokenPayload.Card(
        name: "JOHN DOE",
        number: "4242424242424242",
        expirationMonth: 11,
        expirationYear: 2022,
        securityCode: "123"
    )
    /// Testing createToken API Request.
    /// Testing if `Client` generates URLRequest with correct HTTP body to perform API request
    func testCreateTokenURLRequest() throws {
        let expectation = self.expectation(description: "Create Token Mockup Callback")
        let cardPayload: CreateTokenPayload.Card = try sampleFromJSONBy(.card)

        let networkMockup = NetworkMockup { [cardPayload] urlRequest in
            defer { expectation.fulfill() }

            func validateURLRequest() {
                if let data = urlRequest.httpBody, let jsonString = String(data: data, encoding: .utf8) {
                    do {
                        let decodedCardPayload: CreateTokenPayload = try parse(jsonString: jsonString)
                        XCTAssertEqual(cardPayload, decodedCardPayload.card)
                    } catch {
                        XCTFail("Unable to decode payload from encoded JSON string")
                    }

                } else {
                    XCTFail("Unable to decode payload from encoded JSON string")
                }
            }

            validateURLRequest()
        }

        let client = Client(publicKey: publicKey, network: networkMockup)
        client.createToken(payload: cardPayload) { _ in
            /// Testing URLRequst in through Network Mockup closure
            /// Closure implementation is nor required
        }
        waitForExpectations(timeout: requestTimeout, handler: nil)
    }

    /// Testing createToken API Request.
    /// Testing if `Client` generates URLRequest with correct HTTP body to perform API request
    func testCreateSourceURLRequest() throws {
        let expectation = self.expectation(description: "Create Source Mockup Callback")
        let sourcePayload: CreateSourcePayload = try sampleFromJSONBy(.source(type: .atome))

        let networkMockup = NetworkMockup { [sourcePayload] urlRequest in
            defer { expectation.fulfill() }

            func validateURLRequest() {
                if let data = urlRequest.httpBody, let jsonString = String(data: data, encoding: .utf8) {
                    do {
                        let decodedCardPayload: CreateSourcePayload = try parse(jsonString: jsonString)
                        XCTAssertEqual(sourcePayload, decodedCardPayload)
                    } catch {
                        XCTFail("Unable to decode payload from encoded JSON string")
                    }

                } else {
                    XCTFail("Unable to decode payload from encoded JSON string")
                }
            }

            validateURLRequest()
        }

        let client = Client(publicKey: publicKey, network: networkMockup)
        client.createSource(payload: sourcePayload) { _ in
            /// Testing URLRequst in through Network Mockup closure
            /// Closure implementation is nor required
        }
        waitForExpectations(timeout: requestTimeout, handler: nil)
    }

    // - Mark testClient.userAgent as private
    // - Move this test to testUrlRequest
    func testUserAgent() {
        let sdkVersion = "1.0.0"
        let platform = "12.0.0"
        let device = "iPhone"

        let expectedResult = "OmiseIOS/\(sdkVersion) iOS/\(platform) Apple/\(device)"
        let result = testClient.userAgent(sdkVersion: sdkVersion, platform: platform, device: device)
        XCTAssertEqual(expectedResult, result)
    }

    // - Mark testClient.httpHeaders as private
    // - Move this test to testUrlRequest
    func testHTTPHeaders() {
        let userAgent = "OmiseIOSSDK/3.0.0 iOS/12.0.0 Apple/iPhone"
        let apiVersion = "2019-05-29"
        let contentType = "application/json; charset=utf8"

        let expectedResult = [
            "Authorization": "Basic \(publicKeyBase64)",
            "User-Agent": userAgent,
            "Content-Type": contentType,
            "Omise-Version": apiVersion
        ]

        let result = testClient.httpHeaders(
            publicKey: publicKey,
            userAgent: userAgent,
            apiVersion: apiVersion,
            contentType: contentType
        )
        XCTAssertEqual(expectedResult, result)
    }
}
