# Omise iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/gitter/room/omise/omise-ios.svg?style=flat-square)](https://gitter.im/omise/omise-ios)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@omise.co)

See [v1 branch](https://github.com/omise/omise-ios/tree/v1) for the previous version.

Omise is a payment service provider currently operating in Thailand. Omise provides a set
of clean APIs that helps merchants of any size accept credit cards online.

Omise iOS SDK provides bindings for the Omise
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
github "omise/omise-ios" ~> 2.1
```

And run `carthage bootstrap` or `carthage build` Or run this copy-pastable script for a
quick start:

```
echo 'github "omise/omise-ios" ~> 2.0' >> Cartfile
carthage bootstrap
```

## Usage

If you clone this project to your local hard drive, you can also checkout the `QuickStart`
playground. Otherwise if you'd like all the details, read on:

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

Alternatively you can also push the view controller onto a `UINavigationController` stack
like so:

```swift
@IBAction func displayCreditCardForm() {
  let creditCardView = CreditCardFormController(publicKey: publicKey)
  creditCardView.delegate = self
  creditCardView.handleErrors = true

  navigationController?.pushViewController(creditCardView, animated: true)
}
```

#### Custom Credit Card Form

You can make use of the SDK's text field components to build your own forms:

* `CardNumberTextField` - Provides basic number grouping as the user types.
* `CardNameTextField`
* `CardExpiryDatePicker` - `UIPickerView` implementation that have a month and year
  column.
* `CardCVVTextField` - Masked number field.

Additionally fields also turns red automatically if their content fails basic validation
(e.g. alphabets in number field, or content with wrong length)

#### Manual Tokenization

If you build your own credit card form, you will need to use `OmiseSDKClient` to manually
tokenize the contents. You can do so by first creating and initializing an
`OmiseTokenRequest` like so:

```swift
let request = OmiseTokenRequest(
  name: "John Smith",
  number: "4242424242424242",
  expirationMonth: 10,
  expirationYear: 2019,
  securityCode: "123"
)
```

Then initialize an `OmiseSDKClient` with your public key and send the request:

```swift
let client = OmiseSDKClient(publicKey: publicKey)
client.send(request) { [weak self] (token, error) in
  guard let s = self else { return }

  // check `error` or send `token` to your server.
}
```

Alternatively, delegate style is also supported:

```swift
client.send(request, Handler())

class Handler: OmiseTokenRequestDelegate {
  func tokenRequest(request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken) {
    // handles token
  }

  func tokenRequest(request: OmiseTokenRequest, didFailWithError error: ErrorType) {
    // handle errors
  }
}
```

## Contributing

Pull requests and bugfixes are welcome. For larger scope of work, please pop on to our
[![](https://img.shields.io/gitter/room/omise/omise-ios.svg?style=flat-square)](https://gitter.im/omise/omise-ios)
chatroom to discuss first.

## LICENSE

MIT (See the (full license text)[https://github.com/omise/omise-ios/blob/master/LICENSE])

