import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

final class NetceteraSDKBridgeTests: XCTestCase {
    func test_activeChallengeStatePreventsConcurrentChallenge() {
        let state = ActiveChallengeState()
        let transaction = unsafeBitCast(NSObject(), to: Transaction.self)
        let firstReceiver = BridgeChallengeStatusReceiver()
        let secondReceiver = BridgeChallengeStatusReceiver()

        XCTAssertTrue(state.trySet(transaction: transaction, receiver: firstReceiver))
        XCTAssertFalse(state.trySet(transaction: transaction, receiver: secondReceiver))

        state.clear()
        XCTAssertTrue(state.trySet(transaction: transaction, receiver: secondReceiver))
    }
}
