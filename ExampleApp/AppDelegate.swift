import UIKit
import Combine
import OmiseSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var config = LocalConfig.default
    lazy var settingsStore = InMemoryPaymentSettingsStore(initial: .default(config: config))
    lazy var dependencies = ExampleAppDependencies(settingsStore: settingsStore, config: config)
    private var sdkSettingsCancellable: AnyCancellable?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sdkSettingsCancellable = settingsStore.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.configureSDK(with: settings)
            }

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // No resources to clean up when scenes are discarded.
    }

    private func configureSDK(with settings: PaymentSettings) {
        let resolvedPublicKey = settings.publicKey.isEmpty ? config.publicKey : settings.publicKey
        let sdk = OmiseSDK(publicKey: resolvedPublicKey, configuration: config.configuration)
        if !config.merchantId.isEmpty {
            sdk.setupApplePay(for: config.merchantId, requiredBillingAddress: true)
        }
        sdk.setupSecurePayment(isEnabled: false) // true to disable screenshots
        OmiseSDK.shared = sdk
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        handleIncomingURL(url, options: options)
    }

    @discardableResult
    func handleIncomingURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Determine who sent the URL.
        print("App open url '\(url)'")

        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")

        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid url")
            return false
        }

        switch components.host {
        case AppDeeplink.threeDSChallenge.rawValue:
            print("Omise 3DS Challenge Callback")
            let result = OmiseSDK.shared.handleURLCallback(url)
            if result {
                OmiseSDK.shared.dismiss()
            }
            return result
        default:
            print("Unknown deeplink params \(url.host ?? "nil")")
            return false
        }
    }
}
