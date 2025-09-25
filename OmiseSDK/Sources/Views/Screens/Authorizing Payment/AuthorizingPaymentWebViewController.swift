import Foundation
import WebKit
import os

/*:
 Drop-in authorizing payment handler view controller that automatically display the authorizing payment verification form
 which supports `3DS`, `Internet Banking` and other offsite payment methods those need to be authorized via a web browser.
 
 - remark:
   This is still an experimental API. If you encountered with any problem with this API, please feel free to report to Omise.
 */
@available(iOSApplicationExtension, unavailable)
class AuthorizingPaymentWebViewController: UIViewController {
    /// Authorize URL given from Omise in the created `Charge` object.
    var authorizeURL: URL? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            startAuthorizingPaymentProcess()
        }
    }
    
    enum CompletionState: Equatable {
        case complete(redirectedURL: URL?)
        case cancel
    }

    /// The expected return URL patterns described in the URLComponents object.
    ///
    /// The rule is the scheme and host must be matched and must have the path as a prefix.
    /// Example: if the return URL is `https://www.example.com/products/12345` the expected return URL should have a URLComponents with scheme of `https`, host of `www.example.com` and the path of `/products/`
    var expectedReturnURLStrings: [URLComponents] = []
    
    var completion: ParamClosure<CompletionState> = nil

    let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    let okButtonTitle = NSLocalizedString("OK", comment: "OK button for JavaScript panel")
    let confirmButtonTitle = NSLocalizedString("Confirm", comment: "Confirm button for JavaScript panel")
    let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Cancel button for JavaScript panel")

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAuthorizingPaymentProcess()
    }
    
    @objc func cancelAuthorizingPaymentProcess(_ sender: UIBarButtonItem) {
        os_log("Authorization process was cancelled, trying to notify the delegate", log: uiLogObject, type: .info)
        if let completion = completion {
            completion(.cancel)
        } else {
            os_log("Authorization process was cancelled but no delegate to be notified", log: uiLogObject, type: .default)
        }
    }
    
    private func startAuthorizingPaymentProcess() {
        guard let authorizeURL = authorizeURL, !expectedReturnURLStrings.isEmpty else {
            assertionFailure("Insufficient authorizing payment information")
            os_log("Refusing to initialize sdk client with a non-public key: %{private}@", log: uiLogObject, type: .error)
            return
        }
        
        os_log("Starting the authorizing process with %{private}@ URL", log: uiLogObject, type: .info, authorizeURL.absoluteString)
        let request = URLRequest(url: authorizeURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        webView.load(request)
    }
    
    func verifyPaymentURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        return expectedReturnURLStrings.contains { expectedURLComponents -> Bool in
            components.match(components: expectedURLComponents)
        }
    }
    
}

@available(iOSApplicationExtension, unavailable)
extension AuthorizingPaymentWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, verifyPaymentURL(url) {
            os_log("Redirected to expected %{private}@ URL, trying to notify the delegate",
                   log: uiLogObject,
                   type: .info,
                   url.absoluteString)
            decisionHandler(.cancel)
            completion?(.complete(redirectedURL: url))
            if completion == nil {
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
extension AuthorizingPaymentWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completionHandler()
        }
        
        alertController.addAction(okAction)
        
        // NOTE: Must present an UIAlertController on AuthorizingPaymentWebViewController
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

        // NOTE: Must present an UIAlertController on AuthorizingPaymentWebViewController
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
        
        // NOTE: Must present an UIAlertController on AuthorizingPaymentWebViewController
        self.present(alertController, animated: true, completion: nil)
    }
}
