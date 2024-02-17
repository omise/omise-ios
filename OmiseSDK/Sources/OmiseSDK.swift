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
    ///    - availablePaymentMethods: Custom list of payment methods to be shown in the list
    ///    - showsCreditCardPayment: Should present Card Payment Method in the list
    ///    - delegate: Delegate to be notified when Source or Token is created
    public func presentPaymentOptionViewController(
        from: UIViewController,
        availablePaymentMethods: [SourceType]? = nil,
        showsCreditCardPayment: Bool = true,
        delegate: PaymentCreatorControllerDelegate
    ) {
        
    }
}

public extension OmiseSDK {
    /// Latest capability loaded with `client.capability()`
    var latestLoadedCapability: Capability? { client.latestLoadedCapability }

    /// Country associated with `latestLoadedCapability`
    var country: Country? { Country(code: latestLoadedCapability?.countryCode) }
}
