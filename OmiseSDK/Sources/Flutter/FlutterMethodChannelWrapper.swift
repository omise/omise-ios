import Foundation
import Flutter

/// Protocol to define the methods expected from `FlutterMethodChannel`.
/// This protocol allows mocking or creating alternate implementations for testing.
protocol FlutterMethodChannelProtocol {
    /// Sets the handler for Flutter method calls.
    ///
    /// - Parameter handler: The closure that will be invoked when a method call is made
    ///   from Flutter. The closure is provided with the `FlutterMethodCall` and a result callback.
    func setMethodCallHandler(_ handler: @escaping (FlutterMethodCall, @escaping FlutterResult) -> Void)
}

/// A wrapper class around `FlutterMethodChannel` that conforms to `FlutterMethodChannelProtocol`.
/// This class acts as an intermediary between the actual Flutter method channel and other
/// parts of the code, enabling easier testing and abstraction of the method channel functionality.
class FlutterMethodChannelWrapper: FlutterMethodChannelProtocol {
    
    /// The actual instance of `FlutterMethodChannel` that will handle method calls from Flutter.
    private let channel: FlutterMethodChannel
    
    /// Initializes the wrapper with the provided `FlutterMethodChannel` instance.
    ///
    /// - Parameter channel: The `FlutterMethodChannel` to be wrapped by this class.
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    /// Sets the handler for Flutter method calls.
    ///
    /// This method delegates the setting of the handler to the actual `FlutterMethodChannel`.
    ///
    /// - Parameter handler: The closure to handle method calls from Flutter. The handler
    ///   is provided with the `FlutterMethodCall` and the `FlutterResult` callback to return
    ///   the result to Flutter.
    func setMethodCallHandler(_ handler: @escaping (FlutterMethodCall, @escaping FlutterResult) -> Void) {
        // Delegate the method call handler setup to the real `FlutterMethodChannel`.
        channel.setMethodCallHandler(handler)
    }
}
