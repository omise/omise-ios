import PassKit
@testable import OmiseSDK

/// A mock implementation of ApplePayViewModelType to use in unit tests.
class MockApplePayViewModel: ApplePayViewModelType, ApplePayViewModelInput, ApplePayViewModelOutput {
    
    // MARK: - ApplePayViewModelType
    var input: ApplePayViewModelInput { self }
    var output: ApplePayViewModelOutput { self }
    
    /// Controls whether Apple Pay is available.
    var canMakeApplePayPayment: Bool
    
    /// Records if startPayment was called.
    var startPaymentCalled = false
    /// Scheduler used to invoke the completion; overridable in tests to avoid fixed delays.
    var completionScheduler: (@escaping () -> Void) -> Void = { completion in
        DispatchQueue.main.async {
            completion()
        }
    }
    
    init() {
        canMakeApplePayPayment = true
    }
    
    func setApplePayPaymentModel(_ enable: Bool) {
        self.canMakeApplePayPayment = enable
    }
    
    /// Simulated asynchronous payment start.
    func startPayment(completion: @escaping () -> Void) {
        startPaymentCalled = true
        completionScheduler(completion)
    }
}
