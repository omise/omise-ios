import OmiseSDK
import Combine
import Foundation

protocol PaymentSettingsStore: AnyObject {
    var settings: PaymentSettings { get }
    var settingsPublisher: AnyPublisher<PaymentSettings, Never> { get }
    func update(_ block: (inout PaymentSettings) -> Void)
}

final class InMemoryPaymentSettingsStore: PaymentSettingsStore {
    private let subject: CurrentValueSubject<PaymentSettings, Never>
    
    init(initial: PaymentSettings = .default()) {
        subject = CurrentValueSubject(initial)
    }
    
    var settings: PaymentSettings { subject.value }
    
    var settingsPublisher: AnyPublisher<PaymentSettings, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func update(_ block: (inout PaymentSettings) -> Void) {
        var updatedSettings = subject.value
        block(&updatedSettings)
        subject.send(updatedSettings)
    }
}
