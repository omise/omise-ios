import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(named: "App Tint") ?? UIColor.blue

        #if !INTERNAL_TEST
        /// WORKAROUND:
        /// Storyboards do not trigger the loading of resource bundles in Swift Packages.
        /// Loading Storyboard from OmiseSDK package to use Storyboard Reference in Interface Builder
        Bundle.loadStoryboard(package: "OmiseSDK", target: "OmiseSDK")
        #endif

        return true
    }

}

extension Bundle {
    static func loadStoryboard(package: String, target: String) {
        let bundleName = "\(package)_\(target)"
        guard
            let bundleURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
            preconditionFailure()
        }
        if !bundle.isLoaded {
            bundle.load()
        }
    }
}
