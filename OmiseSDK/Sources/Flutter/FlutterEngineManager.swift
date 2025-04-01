import UIKit
import Flutter

protocol FlutterEngineManager {
    func detachFlutterViewController(animated: Bool)
    func presentFlutterPaymentMethod(
        viewController: UIViewController,  /// The view controller that will present the Flutter payment UI
        arguments: [String: Any], /// arguments that can be passed to flutter module
        delegate: ChoosePaymentMethodDelegate  /// The delegate to handle the result of the payment method selection
    )
}
/// `FlutterEngineManager` is responsible for managing communication between the native iOS SDK
/// and the Flutter-based payment module. It facilitates launching the payment method selection UI,
/// processing the payment result (token or source), and passing the result to the delegate.
/// It also handles the lifecycle of the `FlutterEngine` and detaches the Flutter view controller when done.
class FlutterEngineManagerImpl: FlutterEngineManager {
    let flutterEngine: FlutterEngine  /// The Flutter engine used to run the Flutter code
    let methodChannel: FlutterMethodChannel  /// The method channel used for communication between native iOS and Flutter
    let channelHander: FlutterChannelHandler  /// The handler responsible for processing payment method results
    
    // MARK: - Initialization
    
    /// Initializes a new instance of `FlutterEngineManager` with a given Flutter engine and public key.
    ///
    /// This initializer sets up the `FlutterEngine` and the communication channel between native iOS
    /// and Flutter. It also prepares the channel handler for processing method calls from Flutter.
    ///
    /// - Parameters:
    ///     - flutterEngine: The Flutter engine that will be used to run the Flutter code.
    ///     - publicKey: The public key required for processing Omise APIs.
    init(
        flutterEngine: FlutterEngine,
        methodChannel: FlutterMethodChannel,
        channelHander: FlutterChannelHandler
    ) {
        self.flutterEngine = flutterEngine
        self.methodChannel = methodChannel
        self.channelHander = channelHander
    }
    
    // MARK: - Detach Flutter View Controller
    
    /// Detaches the Flutter view controller from the app when the user has completed the payment method selection.
    ///
    /// Since the Flutter engine supports only one screen at a time, this method dismisses the Flutter view controller
    /// and cleans up the reference to ensure no memory leaks.
    ///
    /// - Parameter animated: A Boolean value indicating whether the dismissal of the Flutter view controller should be animated.
    func detachFlutterViewController(animated: Bool) {
        if let flutterViewController = flutterEngine.viewController {
            flutterViewController.dismiss(animated: animated) {
                self.flutterEngine.viewController = nil  /// Cleanup and release the reference to the Flutter view controller
            }
        }
    }
    
    // MARK: - Present Flutter Payment Method
    
    /// Presents the Flutter payment method selection UI and handles the result via the provided delegate.
    ///
    /// This method initializes the necessary arguments (payment amount, currency, and public key) and invokes
    /// a method on the Flutter side to display the payment method selection UI. The result is then processed
    /// through a delegate, which handles the success or failure of the payment method selection.
    ///
    /// - Parameters:
    ///     - vc: The view controller that will present the Flutter payment UI.
    ///     - amount: The payment amount for the transaction.
    ///     - currency: The currency for the payment.
    ///     - delegate: The delegate that handles the result of the payment method selection.
    ///     - completion: An optional callback that is invoked when the method call has completed.
    func presentFlutterPaymentMethod(
    viewController: UIViewController,  /// The view controller that will present the Flutter payment UI
    arguments: [String: Any],
    delegate: ChoosePaymentMethodDelegate /// The delegate to handle the result of the payment method selection
    ) {
        // Invoke the Flutter method to request the payment method selection UI
        methodChannel.invokeMethod(OmiseFlutter.selectPaymentMethodName, arguments: arguments)
        
        // Create a Flutter view controller to present the payment UI
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: .omiseSDK)
        flutterViewController.view.backgroundColor = .clear
        flutterViewController.modalPresentationStyle = .fullScreen
        
        // Handle the result of the payment method selection
        channelHander.handleSelectPaymentMethodResult { response in
            switch response {
            case .success(let result):
                // If both token and source are present, pass them to the delegate
                if let source = result.source, let token = result.token {
                    delegate.choosePaymentMethodDidComplete(with: source, token: token)
                } else if let source = result.source {
                    delegate.choosePaymentMethodDidComplete(with: source)
                } else if let token = result.token {
                    delegate.choosePaymentMethodDidComplete(with: token)
                }
            case .failure(let error):
                // If there is an error, pass the error to the delegate
                delegate.choosePaymentMethodDidComplete(with: error)
            }
        }
        
        // Present the Flutter view controller
        viewController.present(flutterViewController, animated: true)
    }
}
