import PassKit
@testable import OmiseSDK

/// A mock implementation of ApplePayViewModelType to use in unit tests.
@available(iOS 11.0, *)
class MockApplePayViewModel: ApplePayViewModelType, ApplePayViewModelInput, ApplePayViewModelOutput {
    
    // MARK: - ApplePayViewModelType
    var input: ApplePayViewModelInput { self }
    var output: ApplePayViewModelOutput { self }
    
    /// Controls whether Apple Pay is available.
    var canMakeApplePayPayment: Bool
    
    /// Records if startPayment was called.
    var startPaymentCalled = false
    
    init() {
        canMakeApplePayPayment = true
    }
    
    func setApplePayPaymentModel(_ enable: Bool) {
        self.canMakeApplePayPayment = enable
    }
    
    /// Simulated asynchronous payment start.
    func startPayment(completion: @escaping () -> Void) {
        startPaymentCalled = true
        // Simulate asynchronous completion after 0.1 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }
}
