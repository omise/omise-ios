import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [ApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(named: "App Tint") ?? UIColor.blue
        return true
    }
}
