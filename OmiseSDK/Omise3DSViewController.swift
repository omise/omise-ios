import Foundation
import WebKit


/// Delegate to receive 3DS verification events.
public protocol Omise3DSViewControllerDelegate: class {
    /// A delegation method called when the 3DS verification process is completed.
    /// - parameter viewController: The 3DS verification controller that call this method
    /// - parameter redirectedURL: A URL returned from the 3DS verificataion process.
    func omise3DSViewController(_ viewController: Omise3DSViewController, didComplete3DSProcessWithRedirectedURL redirectedURL: URL)
    /// A delegation method called when user cancel the 3DS verification process.
    func omise3DSViewControllerDidCancel(_ viewController: Omise3DSViewController)
}


/**
 Drop-in 3DS verification handler view controller that automatically display the 3DS verification form
 - remark:
 This is still an experimental API. If you encountered with any problem with this API, please feel free to report to Omise.
 */
public class Omise3DSViewController: UIViewController {
    var webView: WKWebView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    
    /// Authorized URL given from Omise in the created `Charge` object.
    public var authorizedURL: URL? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            start3DSProcess()
        }
    }
    
    /// A delegate object that will recieved the 3DS verification events.
    public weak var delegate: Omise3DSViewControllerDelegate?
    
    /// A factory method for creating a 3DS verification view controller comes in UINavigationController stack.
    ///
    /// - parameter authorizedURL: The authorized URL given in `Charge` object that will be set to `Omise3DSViewController`
    /// - parameter delegate: A delegate object that will recieved 3DS verification events.
    ///
    /// - returns: A UINavigationController with `Omise3DSViewController` as its root view controller
    public static func make3DSViewControllerNavigationWithAuthorizedURL(_ authorizedURL: URL, delegate: Omise3DSViewControllerDelegate) -> UINavigationController {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: Bundle(for: Omise3DSViewController.self))
        let navigationController = storyboard.instantiateViewController(withIdentifier: "Default3DSVerificationControllerWithNavigation") as! UINavigationController
        let viewController = navigationController.topViewController as! Omise3DSViewController
        viewController.authorizedURL = authorizedURL
        viewController.delegate = delegate
        
        return navigationController
    }
    
    /// A factory method for creating a 3DS verification view controller comes in UINavigationController stack.
    ///
    /// - parameter authorizedURL: The authorized URL given in `Charge` object that will be set to `Omise3DSViewController`
    /// - parameter delegate: A delegate object that will recieved 3DS verification events.
    ///
    /// - returns: An `Omise3DSViewController` with given authorized URL and delegate.
    public static func make3DSViewControllerWithAuthorizedURL(_ authorizedURL: URL, delegate: Omise3DSViewControllerDelegate) -> Omise3DSViewController {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: Bundle(for: Omise3DSViewController.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "Default3DSVerificationController") as! Omise3DSViewController
        viewController.authorizedURL = authorizedURL
        viewController.delegate = delegate
        
        return viewController
    }
    
    public override func loadView() {
        super.loadView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        if #available(iOS 9.0, *) {
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        } else {
            let views = ["webView": webView] as [String: UIView]
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "|[webView]|", options: [], metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: views)
            view.addConstraints(constraints)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start3DSProcess()
    }
    
    private func start3DSProcess() {
        guard let authorizedURL = authorizedURL else {
            return
        }
        
        let request = URLRequest(url: authorizedURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        webView.load(request)
    }
    
    fileprivate func verifyPaymentURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else { return false }
        
        let pathComponents = components.path.characters.split(separator: "/").map(String.init)
        return host.hasSuffix("omise.co") && host.hasPrefix("api") && pathComponents.first == "payments" && pathComponents.last == "complete"
    }
    
    @IBAction func cancel3DSProcess(_ sender: UIBarButtonItem) {
        delegate?.omise3DSViewControllerDidCancel(self)
    }
}

extension Omise3DSViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if webView.url.map(verifyPaymentURL) ?? false, let url = navigationAction.request.url {
            decisionHandler(.cancel)
            delegate?.omise3DSViewController(self, didComplete3DSProcessWithRedirectedURL: url)
        } else {
            decisionHandler(.allow)
        }
    }
}

