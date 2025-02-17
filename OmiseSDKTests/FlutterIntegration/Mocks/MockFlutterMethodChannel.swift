import Flutter
@testable import OmiseSDK

// Mock class to simulate the behavior of FlutterMethodChannel for testing purposes.
class MockFlutterMethodChannel: FlutterMethodChannelProtocol {
    
    // A closure that mimics the Flutter method call handler.
    var methodCallHandler: ((FlutterMethodCall, @escaping FlutterResult) -> Void)?
    
    // Set the method call handler. This is called when a method is invoked on the Flutter side.
    // This handler is passed as a closure that takes a FlutterMethodCall and a FlutterResult callback.
    func setMethodCallHandler(_ handler: @escaping (FlutterMethodCall, @escaping FlutterResult) -> Void) {
        self.methodCallHandler = handler
    }
    
    // Simulate a Flutter method call.
    // This method is used to trigger the method call handler programmatically for unit tests.
    // It creates a `FlutterMethodCall` instance with the provided method name and arguments.
    func simulateMethodCall(method: String, arguments: [String: Any]?) {
        // Create a new FlutterMethodCall with the given method name and arguments.
        let call = FlutterMethodCall(methodName: method, arguments: arguments)
        
        // Trigger the method call handler (which was set via `setMethodCallHandler`) with the `call`.
        // The callback is invoked with an empty result (as we are simulating the call).
        methodCallHandler?(call) { _ in }
    }
}
