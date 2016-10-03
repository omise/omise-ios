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
* iOS 8 or higher deployment target.
* Xcode 8.0 or higher.
* Swift 3.0
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
github "omise/omise-ios" ~> 2.4
```

And run `carthage bootstrap` or `carthage build` Or run this copy-pastable script for a
quick start:

```
echo 'github "omise/omise-ios" ~> 2.4' >> Cartfile
carthage bootstrap
```

### Swift 2.x compatible
You can use `Omise iOS SDK` in Swift 2.2 by using Omise iOS SDK version `2.3`

## Usage

If you clone this project to your local hard drive, you can also checkout the `QuickStart`
playground. Otherwise if you'd like all the details, read on:

#### Credit Card Form

The fastest way to get started with this SDK is to display the provided
`CreditCardFormController` in your application. The
`CreditCardFormController` provides a pre-made credit card form and will automatically
[tokenize credit card information](https://www.omise.co/security-best-practices) for you.
You only need to implement two delegate methods and a way to display the form.

##### Use Credit Card Form in code
To use the controller in your application, modify your view controller with the following
additions:

```swift
import OmiseSDK // at the top of the file

class ViewController: UIViewController {
  private let publicKey = "pkey_test_123"

  @IBAction func displayCreditCardForm() {
    let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissCreditCardForm))

    let creditCardView = CreditCardFormController.creditCardFormWithPublicKey(publicKey)
    creditCardView.delegate = self
    creditCardView.handleErrors = true
    creditCardView.navigationItem.rightBarButtonItem = closeButton

    let navigation = UINavigationController(rootViewController: creditCardView)
    present(navigation, animated: true, completion: nil)
  }

  @objc func dismissCreditCardForm() {
    dismiss(animated: true, completion: completion)
  }
}
```

Then implement the delegate to receive the `OmiseToken` object after user has entered the
credit card data:

```swift
extension ViewController: CreditCardFormDelegate {
  func creditCardForm(_ controller: CreditCardFormController, didSucceedWithToken token: OmiseToken) {
    dismissCreditCardForm()

    // Sends `OmiseToken` to your server for creating a charge, or a customer object.
  }

  func creditCardForm(_ controller: CreditCardFormController, didFailWithError error: Error) {
    dismissCreditCardForm()

    // Only important if we set `handleErrors = false`.
    // You can send errors to a logging service, or display them to the user here.
  }
}
```

Alternatively you can also push the view controller onto a `UINavigationController` stack
like so:

```swift
@IBAction func displayCreditCardForm() {
  let creditCardView = CreditCardFormController.creditCardFormWithPublicKey(publicKey)
  creditCardView.delegate = self
  creditCardView.handleErrors = true

  show(creditCardView, sender: self)
}
```

##### Use Credit Card Form in Storyboard
`CreditCardFormController` comes with built in storyboard support. You can use `CreditCardFormController` in your storybard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK`. You can either leave `Referenced ID` empty or use `CreditCardFormController` as a `Referenced ID`
You can setup `CreditCardFormController` in `UIViewController.prepare(for:sender:)` method
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  if segue.identifier == "PresentCreditFormWithModal",
    let creditCardFormNavigationController = segue.destination as? UINavigationController,
    let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormController {
      creditCardFormController.publicKey = publicKey
      creditCardFormController.handleErrors = true
      creditCardFormController.delegate = self

      creditCardFormController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissCreditCardForm))
  }
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
  func tokenRequest(_ request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken) {
    // handles token
  }

  func tokenRequest(_ request: OmiseTokenRequest, didFailWithError error: Error) {
    // handle errors
  }
}
```

## Card.io support
[Card.io](https://www.card.io) is an opensource library for scanning credit cards with your iPhone camera. Omise iOS SDK supports Card.io by integrating it into our `Credit Card Form`.

### Enable Card.io support
Due to the size of Card.io library, we decided to not to include it as a default. If you want the `Card.io` feature in our `Credit Card Form` you have to integrate our SDK manually without `Carthage`

1. Download or clone Omise iOS SDK from github
1. Initialize git submodule in Omise iOS SDK directory using `git submodule update --init` command.
1. Add `OmiseSDK.xcodeproj` project into your Xcode project or workspace
1. Add `OmiseSDK Card.io` Framework Target in Omise iOS SDK repository as your target dependency.
1. Linked against and Embeded `OmiseSDK` Framework into your app.

For more information about target dependency and link to frameworks, please refer to Xcode Help `Building Targets in the Correct Order` and `Link to libraries and frameworks`.


## 3DS Verification
Some merchant require their customers to verify themselves with [3-D Secure verification process](https://www.omise.co/fraud-protection#3-d-secure). Omise iOS SDK provide a built in class to do the verification.

### Using built in 3DS view controller
You can use the built in 3DS verification view controller by creating an instance of `Omise3DSViewController` and set it with `authorized URL` given with the charge.

#### Create an `Omise3DSViewController` by code
You can create an instance of `Omise3DSViewController` by calling its factory method
```swift
let handlerController = Omise3DSViewController.make3DSViewControllerNavigationWithAuthorizedURL(url, delegate: self)
self.present(handlerController, animated: true, completion: nil)
```

#### Use `Omise3DSViewController` in Storyboard
`Omise3DSViewController` also comes with built in storyboard support like `CreditCardFormController`. You can use `Omise3DSViewController` in your storyboard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK` then use `Default3DSVerificationController` as a `Referenced ID`.
You can setup `Omise3DSViewController` in `UIViewController.prepare(for:sender:)` method
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  if segue.identifier == "3DSVerificationController",
    let omise3DSController = segue.destination as? Omise3DSViewController {
      omise3DSController.delegate = self
      omise3DSController.authorizedURL = authorizedURL
  }
}
```

#### Receive `3DS verification` events via the delegate
`Omise3DSViewController` send `3DS verification` events to its `delegate` when there's an event occurred.

```swift
extension ViewController: Omise3DSViewControllerDelegate {
  func omise3DSViewController(_ viewController: Omise3DSViewController, didFinish3DSProcessWithRedirectedURL redirectedURL: URL?) {
    // Handle the `redirected URL` here
  }

  func omise3DSViewControllerDidCancel(_ viewController: Omise3DSViewController) {
    // Handle the case that user tap cancel button.
  }
}
```



## Contributing

Pull requests and bugfixes are welcome. For larger scope of work, please pop on to our
[![](https://img.shields.io/gitter/room/omise/omise-ios.svg?style=flat-square)](https://gitter.im/omise/omise-ios)
chatroom to discuss first.

## LICENSE

MIT [See the full license text](https://github.com/omise/omise-ios/blob/master/LICENSE)

