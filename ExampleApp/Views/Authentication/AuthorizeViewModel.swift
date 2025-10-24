import UIKit
import Combine
import OmiseSDK

struct AuthorizeSummary {
    let maskedPublicKeyText: String
}

final class AuthorizeViewModel {
    struct AuthorizationAlert {
        let title: String
        let message: String
    }
    
    struct AuthorizationHandlingResult {
        let trimmedText: String
        let alert: AuthorizationAlert?
    }
    
    private let settingsStore: PaymentSettingsStore
    private let config: LocalConfig
    private var settingsCancellable: AnyCancellable?
    private var settings: PaymentSettings
    
    var onChange: ((AuthorizeSummary) -> Void)? {
        didSet { onChange?(summary) }
    }
    
    init(settingsStore: PaymentSettingsStore, config: LocalConfig) {
        self.settingsStore = settingsStore
        self.config = config
        self.settings = settingsStore.settings
        settingsCancellable = settingsStore.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                guard let self else { return }
                self.settings = settings
                self.onChange?(self.summary)
            }
    }
    
    private var summary: AuthorizeSummary {
        AuthorizeSummary(maskedPublicKeyText: publicKey.maskedPublicKey)
    }
    
    private var publicKey: String {
        settings.publicKey.isEmpty ? config.publicKey : settings.publicKey
    }
    
    func handleAuthorize(
        urlText: String,
        from viewController: UIViewController,
        delegate: AuthorizingPaymentDelegate
    ) -> AuthorizationHandlingResult {
        let trimmedURLText = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let authorizeURL = Self.makeAuthorizeURL(from: trimmedURLText) else {
            return AuthorizationHandlingResult(
                trimmedText: trimmedURLText,
                alert: .invalidURL
            )
        }
        
        presentAuthorization(from: viewController, authorizeURL: authorizeURL, delegate: delegate)
        return AuthorizationHandlingResult(trimmedText: trimmedURLText, alert: nil)
    }
    
    func presentAuthorization(from viewController: UIViewController, authorizeURL: URL, delegate: AuthorizingPaymentDelegate) {
        let toolbar = ThreeDSToolbarCustomization(
            backgroundColorHex: "#FFFFFF",
            headerText: "Secure Checkout",
            buttonText: "Close",
            textFontName: "HelveticaNeue-Medium",
            textColorHex: "#000000",
            textFontSize: 18
        )
        let customisation = ThreeDSUICustomization(toolbarCustomization: toolbar)
        
        OmiseSDK.shared.presentAuthorizingPayment(
            from: viewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: ["https://omise.co"],
            threeDSRequestorAppURLString: AppDeeplink.threeDSChallenge.urlString,
            threeDSUICustomization: customisation,
            delegate: delegate
        )
    }

    private static func makeAuthorizeURL(from text: String) -> URL? {
        guard !text.isEmpty else { return nil }
        return URL(string: text)
    }
}

private extension AuthorizeViewModel.AuthorizationAlert {
    static let invalidURL = AuthorizeViewModel.AuthorizationAlert(
        title: "Invalid URL",
        message: "Please enter a valid authorize URL."
    )
}
