import UIKit
import Combine
import OmiseSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private lazy var config = LocalConfig.default
    private lazy var settingsStore = InMemoryPaymentSettingsStore(initial: .default(config: config))
    private lazy var dependencies = ExampleAppDependencies(settingsStore: settingsStore, config: config)
    private var sdkSettingsCancellable: AnyCancellable?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sdkSettingsCancellable = settingsStore.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.configureSDK(with: settings)
            }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewModel = MainViewModel(
            settingsStore: dependencies.settingsStore,
            config: dependencies.config
        )
        let rootViewController = MainViewController(
            viewModel: viewModel,
            dependencies: dependencies
        )
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = false

        window.rootViewController = navigationController
        window.tintColor = UIColor(named: "App Tint") ?? UIColor.systemBlue
        window.makeKeyAndVisible()

        self.window = window

        return true
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
