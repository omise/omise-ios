import OmiseSDK
import Combine
import Foundation

struct ExampleSummary {
    let amountText: String
    let currencyText: String
    let paymentMethodText: String
    let capabilityText: String
    let maskedPublicKeyText: String
}

struct PaymentParameters {
    let amount: Int64
    let currencyCode: String
    let allowedMethods: [SourceType]?
}

struct PaymentResult {
    let title: String
    let message: String
    let pasteboardValue: String
}

final class MainViewModel {
    private let settingsStore: PaymentSettingsStore
    private let config: LocalConfig
    private var settingsCancellable: AnyCancellable?
    private var settings: PaymentSettings
    
    var onChange: ((ExampleSummary) -> Void)? {
        didSet { onChange?(summary) }
    }
    
    init(settingsStore: PaymentSettingsStore, config: LocalConfig) {
        self.settingsStore = settingsStore
        self.config = config
        self.settings = settingsStore.settings
        settingsCancellable = settingsStore.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedSettings in
                guard let self else { return }
                self.settings = updatedSettings
                self.onChange?(self.summary)
            }
    }
    
    var summary: ExampleSummary {
        ExampleSummary(
            amountText: formattedAmount(amount: settings.amount, currency: settings.currency),
            currencyText: settings.currency.code,
            paymentMethodText: paymentMethodsDescription,
            capabilityText: settings.usesCapabilityData ? "Capability API" : "Manual selection",
            maskedPublicKeyText: resolvedPublicKey.maskedPublicKey
        )
    }
    
    func paymentParameters() -> PaymentParameters {
        PaymentParameters(
            amount: settings.amount,
            currencyCode: settings.currency.code,
            allowedMethods: settings.usesCapabilityData ? nil : Array(settings.allowedPaymentMethods)
        )
    }

    func paymentResult(for source: Source) -> PaymentResult {
        PaymentResult(
            title: "Source Created\n(\(source.paymentInformation.sourceType.rawValue))",
            message: "A source with id of \(source.id) was successfully created. Send this id to your server to create a charge. ID is copied to your pasteboard.",
            pasteboardValue: source.id
        )
    }

    func paymentResult(for token: Token) -> PaymentResult {
        PaymentResult(
            title: "Token Created",
            message: "A token with id of \(token.id) was successfully created. Send this id to your server to create a charge. ID is copied to your pasteboard.",
            pasteboardValue: token.id
        )
    }

    func paymentResult(for source: Source, token: Token) -> PaymentResult {
        PaymentResult(
            title: "Token & Source Created\n(\(source.paymentInformation.sourceType.rawValue))",
            message: "A token with id of \(token.id) and source id \(source.id) were created. IDs copied to your pasteboard.",
            pasteboardValue: "\(token.id) \(source.id)"
        )
    }
    
    private var resolvedPublicKey: String {
        settings.publicKey.isEmpty ? config.publicKey : settings.publicKey
    }
    
    private var paymentMethodsDescription: String {
        if settings.usesCapabilityData {
            return "Using capability data directly from API"
        }
        let names = settings.allowedPaymentMethods
            .sorted { $0.displayName < $1.displayName }
            .map { $0.displayName }
        if names.isEmpty {
            return "No methods selected"
        } else {
            return names.joined(separator: ", ")
        }
    }
    
    private func formattedAmount(amount: Int64, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        let fractionDigits = currency.factor == identicalBasedCurrencyFactor ? 0 : 2
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        let value = currency.convert(fromSubunit: amount)
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
