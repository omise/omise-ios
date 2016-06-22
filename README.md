# Omise iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/gitter/room/omise/omise-ios.svg?style=flat-square)](https://gitter.im/omise/omise-ios)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@omise.co)

Omise is a payment service provider currently operating in Thailand. Omise provides a set
of clean APIs that helps merchants of any size accept credit cards online.

Omise iOS SDK provides Android bindings for the Omise
[Tokenization](https://www.omise.co/tokens-api) API so you do not need to pass credit card
data to your server as well as components for entering credit card information.

Hop into the Gitter chat (click the badge above) or email our support team if you have any
question regarding this SDK and the functionality it provides.

## Requirements

* Public key. [Register for an Omise account](https://dashboard.omise.co/signup) to obtain your API keys.
* iOS 9 or higher deployment target.
* Xcode 7.0 or higher.
* [Carthage](https://github.com/Carthage/Carthage) dependency manager.

## Merchant Compliance

**Card data should never transit through your server. We recommend that you follow our
guide on how to safely
[collect credit information](https://www.omise.co/collecting-card-information).**

To be authorized to create tokens server-side you must have a currently valid PCI-DSS
Attestation of Compliance (AoC) delivered by a certified QSA Auditor.

This SDK provides means to tokenize card data on end-user mobile phone without the data
having to go through your server.

## Installation

Add the following line to your `Cartfile`:

```
github "omise/omise-ios" ~> 2.0
```

And run `carthage bootstrap` or `carthage build` Or run this copy-pastable script for a
quick start:

```
echo 'github "omise/omise-ios" ~> 2.0' >> Cartfile
carthage bootstrap
```

## Usage

#### Credit Card Popover

The fastest way to get started with this SDK is to display the provided
`CreditCardFormController` as popover from your application. The
`CreditCardFormController` provides a pre-made credit card form and will automatically
[tokenize credit card information](https://www.omise.co/security-best-practices) for you.
You only need to implement two delegate methods and a way to display the form.

To use the controller in popover mode, modify your view controller with the following
additions:

```swift
import OmiseSDK // at the top of the file

class ViewController: UIViewController {
  private let publicKey = "pkey_test_123"

  @IBAction func displayCreditCardForm() {
    let closeButton = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(dismissCreditCardPopover))

    let creditCardView = CreditCardFormController(publicKey: publicKey)
    creditCardView.delegate = self
    creditCardView.handleErrors = true
    creditCardView.navigationItem.rightBarButtonItem = closeButton

    let navigation = UINavigationController(rootViewController: creditCardView)
    presentViewController(navigation, animated: true, completion: nil)
  }

  @objc func dismissCreditCardPopover() {
    presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
```

Then implement the delegate to receive the `OmiseToken` object after user has entered the
credit card data:

```swift
extension ViewController: CreditCardFormDelegate {
  func creditCardPopover(creditCardPopover: CreditCardPopoverController, didSucceededWithToken token: OmiseToken) {
    dismissCreditCardPopover()

    // Sends `OmiseToken` to your server for creating a charge, or a customer object.
  }

  func creditCardPopover(creditCardPopover: CreditCardPopoverController, didFailWithError error: ErrorType) {
    dismissCreditCardPopover()

    // Only important if we set `handleErrors = false`.
    // You can send errors to a logging service, or display them to the user here.
  }
}
```

* CreditCardPopoverController
  * publicKey
  * delegate
  * handleErrors
  * using UINavigation mode
  * using UIPopover mode
* Custom fields.
  * CardCVVTextField
  * CardExpiryDatePicker
  * CardExpiryDateTextField
  * CardNumberTextField
  * NameOnCardField
  * OmiseTextField
* Low-level Toolkit
  * OmiseSDKClient && TokenRequest
  * CardNumber
