import Foundation
@testable import OmiseSDK

class MockApplePayViewModelDelegate: ApplePayViewModelDelegate {
    var didFinishApplePayCalled = false
    var resultPassed: OmiseApplePayResult?
    
    enum Call {
        case didFinishApplePayWith
    }
    
    var calls: [Call] = []
    
    func didFinishApplePayWith(result: OmiseApplePayResult, completion: @escaping () -> Void) {
        didFinishApplePayCalled = true
        resultPassed = result
        calls.append(.didFinishApplePayWith)
        completion()
    }
}
