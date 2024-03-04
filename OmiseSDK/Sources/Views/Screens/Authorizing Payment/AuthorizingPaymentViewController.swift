import Foundation
import WebKit
import os

public protocol AuthorizingPaymentViewControllerDelegate: AnyObject {
    /// A delegation method called when the authorizing payment process is completed.
    /// - parameter viewController: The authorizing payment controller that call this method.
    /// - parameter redirectedURL: A URL returned from the authorizing payment process.
    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL)
    
    /// A delegation method called when user cancel the authorizing payment process.
    func authorizingPaymentViewControllerDidCancel(_ viewController: AuthorizingPaymentViewController)
}

/*:
 Drop-in authorizing payment handler view controller that automatically display the authorizing payment verification form
 which supports `3DS`, `Internet Banking` and other offsite payment methods those need to be authorized via a web browser.
 
 - remark:
   This is still an experimental API. If you encountered with any problem with this API, please feel free to report to Omise.
 */
public class AuthorizingPaymentViewController: UIViewController {
    /// Authorized URL given from Omise in the created `Charge` object.
    var authorizedURL: URL? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            startAuthorizingPaymentProcess()
        }
    }
    
    /// The expected return URL patterns described in the URLComponents object.
    ///
    /// The rule is the scheme and host must be matched and must have the path as a prefix.
    /// Example: if the return URL is `https://www.example.com/products/12345` the expected return URL should have a URLComponents with scheme of `https`, host of `www.example.com` and the path of `/products/`
    var expectedReturnURLPatterns: [URLComponents] = []
    
    /// A delegate object that will recieved the authorizing payment events.
    weak var delegate: AuthorizingPaymentViewControllerDelegate?
    
    let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    let okButtonTitle = NSLocalizedString("OK", comment: "OK button for JavaScript panel")
    let confirmButtonTitle = NSLocalizedString("Confirm", comment: "Confirm button for JavaScript panel")
    let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Cancel button for JavaScript panel")

    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        webView.navigationDelegate = self
        webView.uiDelegate = self

        let cancelButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelAuthorizingPaymentProcess)
        )
        navigationItem.rightBarButtonItem = cancelButtonItem
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAuthorizingPaymentProcess()
    }
    
    @IBAction private func cancelAuthorizingPaymentProcess(_ sender: UIBarButtonItem) {
        os_log("Authorization process was cancelled, trying to notify the delegate", log: uiLogObject, type: .info)
        delegate?.authorizingPaymentViewControllerDidCancel(self)
        if delegate == nil {
            os_log("Authorization process was cancelled but no delegate to be notified", log: uiLogObject, type: .default)
        }
    }
    
    private func startAuthorizingPaymentProcess() {
        guard let authorizedURL = authorizedURL, !expectedReturnURLPatterns.isEmpty else {
            assertionFailure("Insufficient authorizing payment information")
            os_log("Refusing to initialize sdk client with a non-public key: %{private}@", log: uiLogObject, type: .error)
            return
        }
        
        os_log("Starting the authorizing process with %{private}@ URL", log: uiLogObject, type: .info, authorizedURL.absoluteString)
        let request = URLRequest(url: authorizedURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        webView.load(request)
    }
    
    private func verifyPaymentURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        return expectedReturnURLPatterns.contains { expectedURLComponents -> Bool in
            return expectedURLComponents.scheme == components.scheme
                && expectedURLComponents.host == components.host
                && components.path.hasPrefix(expectedURLComponents.path)
        }
    }
    
}

@available(iOSApplicationExtension, unavailable)
extension AuthorizingPaymentViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, verifyPaymentURL(url) {
            os_log("Redirected to expected %{private}@ URL, trying to notify the delegate",
                   log: uiLogObject,
                   type: .info,
                   url.absoluteString)
            decisionHandler(.cancel)
            delegate?.authorizingPaymentViewController(self, didCompleteAuthorizingPaymentWithRedirectedURL: url)
            if delegate == nil {
                os_log("Redirected to expected %{private}@ URL but no delegate to be notified",
                       log: uiLogObject,
                       type: .default,
                       url.absoluteString)
            }
        } else if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased(), scheme != "https" && scheme != "http" {
            os_log("Redirected to custom-scheme %{private}@ URL",
                   log: uiLogObject,
                   type: .debug,
                   navigationAction.request.url?.absoluteString ?? "<empty>")
            
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            os_log("Redirected to non-expected %{private}@ URL",
                   log: uiLogObject,
                   type: .debug,
                   navigationAction.request.url?.absoluteString ?? "<empty>")
            decisionHandler(.allow)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
extension AuthorizingPaymentViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completionHandler()
        }
        
        alertController.addAction(okAction)
        
        // NOTE: Must present an UIAlertController on AuthorizingPaymentViewController
        self.present(alertController, animated: true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
                
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            completionHandler(false)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        // NOTE: Must present an UIAlertController on AuthorizingPaymentViewController
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            completionHandler(nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // NOTE: Must present an UIAlertController on AuthorizingPaymentViewController
        self.present(alertController, animated: true, completion: nil)
    }
}
