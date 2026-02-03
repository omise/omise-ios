import Foundation
import OmiseSDK

extension SettingsViewModel {
    enum Mode: Int, CaseIterable {
        case presets
        case custom
        
        var title: String {
            switch self {
            case .presets:
                return "Preset"
            case .custom:
                return "Setup"
            }
        }
    }
    
    enum CapabilityMode: CaseIterable {
        case capabilityAPI
        case specificMethods
        
        var title: String {
            switch self {
            case .capabilityAPI:
                return "Try Capability API"
            case .specificMethods:
                return "Use specific payment methods"
            }
        }
        
        var detail: String {
            switch self {
            case .capabilityAPI:
                return "Load allowed payment methods from Capability API when available."
            case .specificMethods:
                return "Always use the payment methods specified below."
            }
        }
    }

    struct ToggleOption {
        let title: String
        let detail: String?
        let isOn: Bool
        let isEnabled: Bool
    }
    
    struct CurrencyOption: SelectableOption {
        let currency: PaymentCurrency
        let title: String
        let isSelected: Bool
    }
    
    struct CapabilityOption: SelectableOption {
        let mode: CapabilityMode
        let title: String
        let detail: String
        let isSelected: Bool
    }
    
    struct PaymentMethodOption: SelectableOption {
        let method: SourceType
        let title: String
        let isSelected: Bool
        let isEnabled: Bool
    }
    
    struct PaymentMethodSection {
        let title: String
        let options: [PaymentMethodOption]
    }
    
    struct PresetOption: SelectableOption {
        let definition: PresetDefinition
        let title: String
        let detail: String
        let isSelected: Bool
    }
    
    enum PresetDefinition: CaseIterable {
        case thailand
        case japan
        case singapore
        case malaysia
        
        var title: String {
            switch self {
            case .thailand:
                return "Thailand"
            case .japan:
                return "Japan"
            case .singapore:
                return "Singapore"
            case .malaysia:
                return "Malaysia"
            }
        }
        
        var preset: PaymentPreset {
            switch self {
            case .thailand:
                return .thailandPreset
            case .japan:
                return .japanPreset
            case .singapore:
                return .singaporePreset
            case .malaysia:
                return .malaysiaPreset
            }
        }
    }
}
