import Foundation
@testable import OmiseSDK

class MockChoosePaymentMethodDelegate: ChoosePaymentMethodDelegate {
    enum Call {
        case choosePaymentMethodDidComplete
        case choosePaymentMethodDidCancel
    }
    
    var calls: [Call] = []
    var source: Source?
    var token: Token?
    var error: Error?
    
    func choosePaymentMethodDidComplete(with source: Source) {
        calls.append(.choosePaymentMethodDidComplete)
        self.source = source
    }
    
    func choosePaymentMethodDidComplete(with token: Token) {
        calls.append(.choosePaymentMethodDidComplete)
        self.token = token
    }
    
    func choosePaymentMethodDidComplete(with source: Source, token: Token) {
        calls.append(.choosePaymentMethodDidComplete)
        self.source = source
        self.token = token
    }
    
    func choosePaymentMethodDidComplete(with error: any Error) {
        calls.append(.choosePaymentMethodDidComplete)
        self.error = error
    }
    
    func choosePaymentMethodDidCancel() {
        calls.append(.choosePaymentMethodDidCancel)
    }
    
}
