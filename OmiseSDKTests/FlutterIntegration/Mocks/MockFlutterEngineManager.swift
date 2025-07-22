import Flutter
@testable import OmiseSDK

final class MockFlutterEngineManager: FlutterEngineManager {
    /// Captures a single present call in a type‐safe, line‐length‐friendly way.
    struct PresentCall {
        let method: OmiseFlutterMethod
        let viewController: UIViewController
        let arguments: [String: Any]
        let delegate: ChoosePaymentMethodDelegate
    }
    
    private(set) var didDetach = false
    private(set) var presentCalls = [PresentCall]()
    
    func detachFlutterViewController(animated: Bool) {
        didDetach = true
    }
    
    func presentFlutterViewController(
        for method: OmiseFlutterMethod,
        on viewController: UIViewController,
        arguments: [String: Any],
        delegate: ChoosePaymentMethodDelegate
    ) {
        let call = PresentCall(
            method: method,
            viewController: viewController,
            arguments: arguments,
            delegate: delegate
        )
        presentCalls.append(call)
    }
}
