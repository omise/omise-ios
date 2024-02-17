import Foundation
import UIKit

public class OmiseSDK {
    /// Static container that allows to assign a shared instance of OmiseSDK to be used as a Singleton object
    public static var shared = OmiseSDK(publicKey: "")

    /// OmiseSDK version
    public let version: String = "5.0.0"

    /// Public Key associated with this instance of OmiseSDK
    public let publicKey: String

    /// Client is used to communicate with Omise API
    public let client: Client

    /// Creates a new instance of Omise SDK that provides interface to functionallity that SDK provides
    ///
    /// - Parameters:
    ///    - publicKey: Omise public key
    ///    - configuration: Optional configuration is used for testing
    public init(publicKey: String, configuration: Configuration? = nil) {
        self.publicKey = publicKey
        self.client = Client(
            publicKey: publicKey,
            network: NetworkService(),
            apiURL: configuration?.apiURL,
            vaultURL: configuration?.vaultURL
        )
    }

    /// Presents controller with Payment Methods list
    ///
    /// - Parameters:
    ///    - from: ViewController is used as a base to present UINavigationController
    ///    - allowedPaymentMethods: Custom list of payment methods to be shown in the list. If value is nill then SDK will load list from Capability API
    ///    - showsCreditCardPayment: Should present Card Payment Method in the list
    ///    - delegate: Delegate to be notified when Source or Token is created
    public func makeChoosePaymentMethodController(
        allowedPaymentMethods: [SourceType]? = nil,
        showsCreditCardPayment: Bool = true,
        paymentAmount: Int64,
        paymentCurrency: String,
        completion: @escaping PaymentResultClosure
    ) -> UINavigationController {
        let paymentFlow = PaymentFlow(
            client: client,
            amount: paymentAmount,
            currency: paymentCurrency
        )

        /// If allowedPaymentMethods is empty or nil then load it from Capability
        let useCapability = allowedPaymentMethods?.isEmpty ?? true
        let viewController = paymentFlow.createRootViewController(
            allowedPaymentMethods: allowedPaymentMethods ?? [],
            usePaymentMethodsFromCapability: useCapability,
            completion: completion
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}

public extension OmiseSDK {
    /// Latest capability loaded with `client.capability()`
    var latestLoadedCapability: Capability? { client.latestLoadedCapability }

    /// Country associated with `latestLoadedCapability`
    var country: Country? { Country(code: latestLoadedCapability?.countryCode) }
}
