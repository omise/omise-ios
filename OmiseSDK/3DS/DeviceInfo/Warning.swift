import Foundation

public enum Warning {
    case deviceIsJailbroken
    case tamperedSDKIntegrity
    case runOnSimulator
    case debuggerIsAttached
    case osNotSupported

    public enum Severity {
        case low
        case medium
        case high
    }

    public var id: String {
        switch self {
        case .deviceIsJailbroken: return "SW01"
        case .tamperedSDKIntegrity: return "SW02"
        case .runOnSimulator: return "SW03"
        case .debuggerIsAttached: return "SW04"
        case .osNotSupported: return "SW05"
        }
    }
    public var message: String {
        switch self {
        case .deviceIsJailbroken:
            return "The device is jailbroken."
        case .tamperedSDKIntegrity:
            return "The integrity of the SDK has been tampered."
        case .runOnSimulator:
            return "An emulator is being used to run the App."
        case .debuggerIsAttached:
            return "A debugger is attached to the App."
        case .osNotSupported:
            return "The OS or the OS version is not supported."
        }
    }

    public var severity: Severity {
        switch self {
        case .deviceIsJailbroken: return .high
        case .tamperedSDKIntegrity: return .high
        case .runOnSimulator: return .high
        case .debuggerIsAttached: return .medium
        case .osNotSupported: return .high
        }
    }
}
