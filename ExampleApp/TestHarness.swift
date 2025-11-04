import Foundation
import UIKit
import OmiseSDK

enum MockConfiguration {
    static var shouldSimulateError = false
    static var simulatedErrorMessage = "Mock network error"
}

enum SimpleTestHarness {
    
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }
    
    static var isMockMode: Bool {
        ProcessInfo.processInfo.environment["OMISE_MOCK_MODE"] == "true"
    }
}
