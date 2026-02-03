import XCTest
@testable import OmiseSDK

final class NetceteraSDKErrorsTests: XCTestCase {
    func test_configErrorEquality() {
        XCTAssertEqual(NetceteraSDKConfigError.invalidKeyEncoding, .invalidKeyEncoding)
        XCTAssertNotEqual(NetceteraSDKConfigError.invalidKeyEncoding, .apiKeyInvalid)
        let crypto1 = NetceteraSDKConfigError.cryptoError(LocalMockError.defaultError)
        let crypto2 = NetceteraSDKConfigError.cryptoError(LocalMockError.defaultError)
        XCTAssertEqual(crypto1, crypto2)
    }

    func test_bridgeErrorEquality() {
        XCTAssertEqual(NetceteraSDKBridgeError.cancelled, .cancelled)
        XCTAssertEqual(NetceteraSDKBridgeError.timedOut, .timedOut)
        XCTAssertEqual(NetceteraSDKBridgeError.protocolError(event: nil), .protocolError(event: nil))
        XCTAssertEqual(NetceteraSDKBridgeError.runtimeError(event: nil), .runtimeError(event: nil))
        XCTAssertEqual(NetceteraSDKBridgeError.incomplete(event: nil), .incomplete(event: nil))

        XCTAssertNotEqual(NetceteraSDKBridgeError.cancelled, .timedOut)
    }
}

private enum LocalMockError: Error {
    case defaultError
}
