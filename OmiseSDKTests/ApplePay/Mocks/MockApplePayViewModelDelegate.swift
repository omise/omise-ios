import Foundation
@testable import OmiseSDK

class MockApplePayViewModelDelegate: ApplePayViewModelDelegate {
    var didFinishApplePayCalled = false
    var resultPassed: OmiseApplePayResult?
    
    func didFinishApplePayWith(result: OmiseApplePayResult, completion: @escaping () -> Void) {
        didFinishApplePayCalled = true
        resultPassed = result
        completion()
    }
}
