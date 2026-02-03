import UIKit
import Combine
import OmiseSDK

protocol SelectableOption {
    var title: String { get }
    var isSelected: Bool { get }
}

final class SettingsViewModel {
    typealias PaymentCurrency = Currency

    private let settingsStore: PaymentSettingsStore
    private var settingsCancellable: AnyCancellable?
    private(set) var mode: Mode = .custom
    private var settings: PaymentSettings

    enum Section: Equatable {
        case presets
        case payment
        case capability
        case installments
        case paymentMethods(index: Int)
        case developer
    }

    var onChange: (() -> Void)? {
        didSet { onChange?() }
    }
    
    init(settingsStore: PaymentSettingsStore) {
        self.settingsStore = settingsStore
        self.settings = settingsStore.settings
        settingsCancellable = settingsStore.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedSettings in
                guard let self else { return }
                self.settings = updatedSettings
                self.notifyChange()
            }
    }
    
    func selectMode(_ newMode: Mode) {
        guard mode != newMode else { return }
        mode = newMode
        notifyChange()
    }

    var sections: [Section] {
        switch mode {
        case .presets:
            return [.presets]
        case .custom:
            var sections: [Section] = [.payment, .capability, .installments]
            sections.append(contentsOf: paymentMethodSections.indices.map { Section.paymentMethods(index: $0) })
            sections.append(.developer)
            return sections
        }
    }

    func section(at index: Int) -> Section? {
        guard index >= 0 && index < sections.count else { return nil }
        return sections[index]
    }

    func numberOfRows(in section: Section) -> Int {
        switch section {
        case .presets:
            return presets.count
        case .payment:
            return 1 + currencyOptions.count
        case .capability:
            return capabilityOptions.count
        case .installments:
            return 1
        case .paymentMethods(let index):
            guard paymentMethodSections.indices.contains(index) else { return 0 }
            return paymentMethodSections[index].options.count
        case .developer:
            return 1
        }
    }

    func headerTitle(for section: Section) -> String? {
        switch section {
        case .presets:
            return "Choose a preset"
        case .payment:
            return "Payment"
        case .capability:
            return "Payment Methods"
        case .installments:
            return "Installments"
        case .paymentMethods(let index):
            guard paymentMethodSections.indices.contains(index) else { return nil }
            return paymentMethodSections[index].title
        case .developer:
            return "Developer"
        }
    }

    func footerTitle(for section: Section) -> String? {
        switch section {
        case .payment:
            return amountHelpText
        case .presets, .capability, .paymentMethods, .developer:
            return nil
        case .installments:
            return "Whether merchant absorbs the interest for installment payments."
        }
    }

    var amountText: String {
        formattedAmount(amount: settings.amount, currency: settings.currency)
    }
    
    var amountPlaceholder: String {
        let preset = PaymentPreset.thailandPreset
        let formatter = NumberFormatter()
        let fractionDigits = preset.paymentCurrency.factor == identicalBasedCurrencyFactor ? 0 : 2
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        let value = preset.paymentCurrency.convert(fromSubunit: preset.paymentAmount)
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    var amountHelpText: String {
        "The amount will be used when you create a source, not a credit card token."
    }
    
    var currentCurrency: PaymentCurrency { settings.currency }
    
    var amountKeyboardType: UIKeyboardType {
        settings.currency.factor == identicalBasedCurrencyFactor ? .numberPad : .decimalPad
    }
    
    var currencyOptions: [CurrencyOption] {
        let currencies: [PaymentCurrency] = [.thb, .jpy, .usd, .sgd, .myr]
        return currencies.map { currency in
            let currencyName = Locale.current.localizedString(forCurrencyCode: currency.code) ?? currency.code
            return CurrencyOption(
                currency: currency,
                title: "\(currency.code) – \(currencyName)",
                isSelected: settings.currency == currency
            )
        }
    }
    
    var capabilityOptions: [CapabilityOption] {
        CapabilityMode.allCases.map { mode in
            CapabilityOption(
                mode: mode,
                title: mode.title,
                detail: mode.detail,
                isSelected: isUsingCapabilityData == (mode == .capabilityAPI)
            )
        }
    }

    var installmentToggleOption: ToggleOption {
        ToggleOption(
            title: "Zero interest installments",
            detail: nil,
            isOn: settings.zeroInterestInstallments,
            isEnabled: true
        )
    }
    
    var capabilityInfoText: String {
        [
            "\"Try Capability API\" will try to load the allowed payment methods from the Capability API and use it if it's available.",
            "\"Use specific payment methods\" will ignore the allowed payment methods from the Capability API",
            "and always use the payment method specified below."
        ].joined(separator: " ")
    }
    
    var paymentMethodSections: [PaymentMethodSection] {
        PaymentMethodCatalog.Group.allCases.compactMap { group in
            let options = PaymentMethodCatalog.entries(in: group).map { entry in
                PaymentMethodOption(
                    method: entry.sourceType,
                    title: entry.displayName,
                    isSelected: settings.allowedPaymentMethods.contains(entry.sourceType),
                    isEnabled: !settings.usesCapabilityData
                )
            }
            
            guard !options.isEmpty else { return nil }
            return PaymentMethodSection(title: group.title, options: options)
        }
    }
    
    var publicKey: String {
        settings.publicKey
    }
    
    var publicKeyPlaceholder: String { "pkey_test_123" }
    
    var presets: [PresetOption] {
        PresetDefinition.allCases.map { definition in
            let preset = definition.preset
            let isSelected = settings.amount == preset.paymentAmount && settings.currency == preset.paymentCurrency
            let detail = "\(formattedAmount(amount: preset.paymentAmount, currency: preset.paymentCurrency)) \(preset.paymentCurrency.code)"
            return PresetOption(
                definition: definition,
                title: definition.title,
                detail: detail,
                isSelected: isSelected
            )
        }
    }

    var isUsingCapabilityData: Bool {
        settings.usesCapabilityData
    }

    func updateAmount(with text: String) {
        let sanitized = text.replacingOccurrences(of: ",", with: "")
        guard !sanitized.isEmpty, let decimal = Decimal(string: sanitized) else { return }
        updateAmount(from: decimal)
    }

    func updateAmount(from decimal: Decimal) {
        let doubleValue = NSDecimalNumber(decimal: decimal).doubleValue
        settingsStore.update { settings in
            settings.amount = settings.currency.convert(toSubunit: doubleValue)
        }
    }
    
    func selectCurrency(_ currency: PaymentCurrency) {
        settingsStore.update { settings in
            switch (settings.currency.factor, currency.factor) {
            case (identicalBasedCurrencyFactor, centBasedCurrencyFactor):
                settings.amount *= 100
            case (centBasedCurrencyFactor, identicalBasedCurrencyFactor):
                settings.amount /= 100
            default:
                break
            }
            settings.currency = currency
        }
    }
    
    func selectCapabilityMode(_ mode: CapabilityMode) {
        settingsStore.update { settings in
            settings.usesCapabilityData = (mode == .capabilityAPI)
        }
    }

    func toggleZeroInterestInstallments(_ isOn: Bool) {
        settingsStore.update { settings in
            settings.zeroInterestInstallments = isOn
        }
    }
    
    func togglePaymentMethod(_ method: SourceType) {
        guard !settings.usesCapabilityData else { return }
        settingsStore.update { settings in
            if settings.allowedPaymentMethods.contains(method) {
                settings.allowedPaymentMethods.remove(method)
            } else {
                settings.allowedPaymentMethods.insert(method)
            }
        }
    }
    
    func updatePublicKey(_ newValue: String) {
        settingsStore.update { settings in
            settings.publicKey = newValue
        }
    }
    
    func applyPreset(_ definition: PresetDefinition) {
        let preset = definition.preset
        settingsStore.update { settings in
            settings.applyPreset(preset)
            settings.usesCapabilityData = true
        }
    }
    
    private func notifyChange() {
        onChange?()
    }
    
    private func formattedAmount(amount: Int64, currency: PaymentCurrency) -> String {
        let formatter = NumberFormatter()
        let fractionDigits = currency.factor == identicalBasedCurrencyFactor ? 0 : 2
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        let value = currency.convert(fromSubunit: amount)
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}
