import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let dependencies = appDelegate.dependencies
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
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.tintColor = UIColor(named: "App Tint") ?? UIColor.systemBlue
        window.makeKeyAndVisible()
        
        self.window = window
        
        if let urlContext = connectionOptions.urlContexts.first {
            appDelegate.handleIncomingURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        URLContexts.forEach { context in
            appDelegate.handleIncomingURL(context.url)
        }
    }
}
