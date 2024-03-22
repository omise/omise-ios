import UIKit
import OmiseSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(named: "App Tint") ?? UIColor.blue

        return true
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
