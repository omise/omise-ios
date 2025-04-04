import UIKit
import Flutter

/// A structure that contains the result of the payment method selection.
///
/// This structure holds both the `token` and `source` that are selected as part
/// of the payment method selected from Flutter screen.
struct FlutterPaymentMethodResult {
    /// The token associated with the payment method selected.
    ///
    /// This token can be used for further payment processing.
    let token: Token?
    
    /// The source associated with the payment method selected.
    ///
    /// Represents Source JSON object for communication with Omise API
    /// Sources are methods for accepting payments through non-credit-card channels
    let source: Source?
}

/// A typealias for the callback used when handling the result of the payment method selection.
///
/// - Parameters:
///     - result: The result of the payment method selection, either success or failure with an error.
///
/// This callback is called when the payment method result is selected from flutter UI.
typealias FlutterPaymentMethodCallback = (Result<FlutterPaymentMethodResult, Error>) -> Void

/// Protocol for handling Flutter channel communication related to selected payment method type.
protocol FlutterChannelHandler {
    
    /// Handles the result of the payment method selection from the Flutter channel.
    ///
    /// This method decodes the payment method result, processes the token and source, and
    /// calls the provided completion callback with the appropriate result.
    ///
    /// - Parameter completion: The callback that will be called with the result, either success or failure.
    func handleSelectPaymentMethodResult(completion: @escaping FlutterPaymentMethodCallback)
}

/// Implementation of `FlutterChannelHandler` that communicates with Flutter via a method channel.
final class FlutterChannelHandlerImpl: FlutterChannelHandler {
    
    /// The custom Flutter method channel protocol used for communication between the app and Flutter.
    /// Protocol is used for method channel wrapper for testing purposes
    private let channel: FlutterMethodChannelProtocol
    
    /// Initializes a new `FlutterChannelHandlerImpl` with the provided method channel.
    ///
    /// - Parameter channel: The Flutter method channel used for communication.
    init(channel: FlutterMethodChannelProtocol) {
        self.channel = channel
    }
    
    /// Handles the result of the payment method selection from Flutter and decodes the response.
    ///
    /// This method listens for a method call from Flutter, decodes the arguments into a token and
    /// source, and calls the completion handler with the result. If the arguments are invalid, an error
    /// is returned via the completion handler.
    ///
    /// - Parameter completion: A closure to be executed when the result is processed.
    func handleSelectPaymentMethodResult(completion: @escaping FlutterPaymentMethodCallback) {
        channel.setMethodCallHandler { [weak self] call, result in
            if self == nil { return }
            
            switch call.method {
            case OmiseFlutter.selectPaymentMethodResult:
                // Handle the result of the payment method selection
                guard let arguments = call.arguments as? [String: Any] else {
                    // Return an error if arguments are invalid or not found
                    // If flutter returns no arguments, it means user has pressed the close button
                    result("Payment method result processed")
                    completion(.failure(NSError(domain: "com.omise.omiseSDK",
                                                code: OmiseFlutter.selectPaymentMethodResultCancelled,
                                                userInfo: [NSLocalizedDescriptionKey: "Arguments not found or cancelled"])))
                    return
                }
                
                // Decode the token and source from the arguments
                let token: Token? = arguments["token"].decode(to: Token.self)
                let source: Source? = arguments["source"].decode(to: Source.self)
                
                // Handle the case where either token or source is missing
                if token == nil, source == nil {
                    let error = NSError(domain: "com.omise.omiseSDK",
                                        code: 1001,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing source and token"])
                    completion(.failure(error))
                } else {
                    // Return the result if both token and source are available
                    completion(.success(FlutterPaymentMethodResult(token: token, source: source)))
                }
                
                // Return a response indicating that the payment method result has been processed
                result("Payment method result processed")
                
            default:
                // Return method not implemented for other method calls
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
