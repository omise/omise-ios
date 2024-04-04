//
//  AuthorizingPayment.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/11/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
public class AuthorizingPayment {
    public enum Status: Equatable {
        case complete(redirectURL: URL?)
        case cancel
    }

    private var completion: ((Status) -> Void)?
    private var topViewController: UIViewController?

    public static var shared = AuthorizingPayment()

    // Temporary POC Solution
    public func setAPIKey(_ apiKey: String) {
        NetceteraThreeDSController.sharedController.setAPIKey(apiKey)
    }

    public func appOpen3DSDeeplinkURL(_ url: URL) -> Bool {
        NetceteraThreeDSController.sharedController.appOpen3DSDeeplinkURL(url)
    }

    public func presentAuthPaymentController(
        from topViewController: UIViewController,
        url: URL,
        expectedWebViewReturnURL: URL,
        deeplinkURL: URL,
        uiCustomization: ThreeDSUICustomization? = nil,
        completion: @escaping ((Status) -> Void)
    ) {
        self.completion = completion
        self.topViewController = topViewController

        guard url.absoluteString.contains("acs=true") else {
            presentAuthPaymentController(
                topViewController: topViewController,
                url: url,
                expectedReturnURL: expectedWebViewReturnURL
            )
            return
        }

        NetceteraThreeDSController.sharedController.processAuthorizedURL(
            url,
            threeDSRequestorAppURL: deeplinkURL.absoluteString,
            uiCustomization: uiCustomization,
            in: topViewController) { [weak self] result in
                switch result {
                case .success:
                    completion(.complete(redirectURL: nil))
                case .failure(let error):
                    typealias NetceteraFlowError = NetceteraThreeDSController.Errors
                    switch error {
                    case NetceteraFlowError.incomplete,
                        NetceteraFlowError.cancelled,
                        NetceteraFlowError.timedout,
                        NetceteraFlowError.authResStatusFailed,
                        NetceteraFlowError.authResStatusUnknown:
                        completion(.cancel)
                    default:
                        DispatchQueue.main.async {
                            self?.presentAuthPaymentController(
                                topViewController: topViewController,
                                url: url,
                                expectedReturnURL: expectedWebViewReturnURL
                            )
                        }
                    }
                }
        }
    }

    private func presentAuthPaymentController(topViewController: UIViewController, url: URL, expectedReturnURL: URL) {
        guard let returnURLComponents = URLComponents(url: expectedReturnURL, resolvingAgainstBaseURL: false) else {
            return
        }

        let handlerController =
        AuthorizingPaymentWebViewController
            .makeAuthorizingPaymentWebViewControllerNavigationWithAuthorizedURL(
                url, expectedReturnURLPatterns: [returnURLComponents], delegate: self)
        topViewController.present(handlerController, animated: true, completion: nil)
    }
}

@available(iOSApplicationExtension, unavailable)
extension AuthorizingPayment: AuthorizingPaymentWebViewControllerDelegate {
    public func authorizingPaymentWebViewController(_ viewController: AuthorizingPaymentWebViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
        completion?(.complete(redirectURL: redirectedURL))
        topViewController?.dismiss(animated: true, completion: nil)
    }

    public func authorizingPaymentWebViewControllerDidCancel(_ viewController: AuthorizingPaymentWebViewController) {
        completion?(.cancel)
        topViewController?.dismiss(animated: true, completion: nil)
    }
}
