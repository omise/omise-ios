@testable import OmiseSDK
import Foundation

class MockChoosePaymentMethodDelegate: ChoosePaymentMethodDelegate {
    var paymentMethodCompleted: Bool = false
    var errorReceived: NSError?
    var tokenReceived: Token?
    var sourceReceived: Source?
    
    func choosePaymentMethodDidComplete(with source: Source) {
        sourceReceived = source
        paymentMethodCompleted = true
    }
    
    func choosePaymentMethodDidComplete(with token: Token) {
        tokenReceived = token
        paymentMethodCompleted = true
    }
    
    func choosePaymentMethodDidComplete(with source: Source, token: Token) {
        sourceReceived = source
        tokenReceived = token
        paymentMethodCompleted = true
    }
    
    func choosePaymentMethodDidComplete(with error: any Error) {
        errorReceived = error as NSError
        paymentMethodCompleted = true
    }
    
    func choosePaymentMethodDidCancel() {
        errorReceived = nil
        paymentMethodCompleted = false
    }
}
