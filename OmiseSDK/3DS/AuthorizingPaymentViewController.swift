//
//  AuthorizingPaymentViewController.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/11/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

/// Delegate to receive authorizing payment events.
@objc(OMSAuthorizingPaymentViewControllerDelegate)
@available(iOSApplicationExtension, unavailable)
// swiftlint:disable:next attributes type_name
public protocol AuthorizingPaymentViewControllerDelegate: AnyObject {
    /// A delegation method called when the authorizing payment process is completed.
    /// - parameter viewController: The authorizing payment controller that call this method.
    /// - parameter redirectedURL: A URL returned from the authorizing payment process.
    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL)

    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, willRedirectToAuthorizingPaymentAppWithRedirectedURL redirectedURL: URL)

    /// A delegation method called when user cancel the authorizing payment process.
    func authorizingPaymentViewControllerDidCancel(_ viewController: AuthorizingPaymentViewController)
}


@objc(OMSAuthorizingPaymentViewController)
@available(iOSApplicationExtension, unavailable)
// swiftlint:disable:next attributes
public class AuthorizingPaymentViewController: UIViewController {

}
