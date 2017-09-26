# Omise iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@omise.co)
[![](https://img.shields.io/badge/discourse-forum-1a53f0.svg?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAqlJREFUKBU9UVtLVFEU%2FvY%2B27mPtxl1dG7HbNRx0rwgFhJBPohBL9JTZfRQ0YO9RU%2FVL6iHCIKelaCXqIewl4gEBbEyxSGxzKkR8TbemmbmnDlzVvsYtOHbey1Y317fWh8DwCVMCfSHww3ElCs7CjuzbOcNIaEo9SbtlDRjZiNPY%2BvrqSWrTh7l3yPvrmh0KBZW59HcREjEqcGpElAuESRxopU648dTwfrIyH%2BCFXSH1cFgJLqHlma6443SG0CfqYY2NZjQnkV8eiMgP6ijjnizHglErlocdl5VA0mT3v102dseL2W14cYM99%2B9XGY%2FlQArd8Mo6JhbSJUePHytvf2UdnW0qen93cKQ4nWXX1%2FyOkZufsuZN0L7PPzkthDDZ4FQLajSA6XWR8HWIK861sCfj68ggGwl83mzfMclBmAQ%2BktrqBu9wOhcD%2BB0ErSiFFyEkdcYhKD27mal9%2F5FY36b4BB%2FTvO8XdQhlUe11F3WG2fc7QLlC8wai3MGGQCGDkcZQyymCqAPSmati3s45ygWseeqADwuWS%2F3wGS5hClDMMstxvJFHQuGU26yHsY6iHtL0sIaOyZzB9hZz0hHZW71kySSl6LIJlSgj5s5LO6VG53aFgpOfOFCyoFmYsOS5HZIaxVwKYsLSbJJn2kfU%2BlNdms5WMLqQRklX0FX26eFRnKYwzX0XRsgR0uUrWxplM7oqPIq8r8cZrdLNLqaABayxZMTTx2HVfglbP4xkcvqZEMNfmglevRi1ny5mGfJfTuQiBEq%2FMBvG0NqDh2TY47sbtJAuO%2Fe9%2Fn3STRFosm2WIxsFSFrFUfwHb11JNBNcaZSp8yb%2FEhHW3suWRNZRzDGvxb0oifk5lmnX2V2J2dEJkX1Q0baZ1MvYXPXHvhAga7x9PTEyj8a%2BF%2BXbxiTn78bSQAAAABJRU5ErkJggg%3D%3D)](https://forum.omise.co)


See [v1 branch](https://github.com/omise/omise-ios/tree/v1) for the previous version.

Omise is a payment service provider currently operating in Thailand. Omise provides a set
of clean APIs that helps merchants of any size accept credit cards online.

Omise iOS SDK provides bindings for the Omise
[Tokenization](https://www.omise.co/tokens-api) API so you do not need to pass credit card
data to your server as well as components for entering credit card information.

Hop into our forum (click the badge above) or email our support team if you have any
question regarding this SDK and the functionality it provides.

## Requirements

* Public key. [Register for an Omise account](https://dashboard.omise.co/signup) to obtain your API keys.
* iOS 8 or higher deployment target.
* Xcode 9.0 or higher.
* Swift 4.0
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
github "omise/omise-ios" ~> 2.6
```

And run `carthage bootstrap` or `carthage build` Or run this copy-pastable script for a
quick start:

```
echo 'github "omise/omise-ios" ~> 2.6' >> Cartfile
carthage bootstrap
```

### Swift 3.x compatible
You can use `Omise iOS SDK` in Swift 3.2 by using Omise iOS SDK version `2.5`

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

    let creditCardView = CreditCardFormController.makeCreditCardForm(withPublicKey: publicKey)
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


## Authorizing Payment
Some payment method require the customers to authorize the payment via an authorized URL. This includes the [3-D Secure verification](https://www.omise.co/fraud-protection#3-d-secure), [Internet Banking payment](https://www.omise.co/offsite-payment), [Alipay](https://www.omise.co/alipay) and etc. Omise iOS SDK provide a built in class to do the authorization.

### Using built in Authorizing Payment view controller
You can use the built in Authorizing Payment view controller by creating an instance of `OmiseAuthorizingPaymentViewController` and set it with `authorized URL` given with the charge and expected `return URL` patterns those were created by merchants.

#### Create an `OmiseAuthorizingPaymentViewController` by code
You can create an instance of `OmiseAuthorizingPaymentViewController` by calling its factory method
```swift
let handlerController = OmiseAuthorizingPaymentViewController.makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
self.present(handlerController, animated: true, completion: nil)
```

#### Use `OmiseAuthorizingPaymentViewController` in Storyboard
`OmiseAuthorizingPaymentViewController` also comes with built in storyboard support like `CreditCardFormController`. You can use `OmiseAuthorizingPaymentViewController` in your storyboard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK` then use `DefaultAuthorizingPaymentViewController` as a `Referenced ID`.
You can setup `OmiseAuthorizingPaymentViewController` in `UIViewController.prepare(for:sender:)` method
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  if segue.identifier == "AuthorizingPaymentViewController",
    let omiseAuthorizingPaymentController = segue.destination as? OmiseAuthorizingPaymentViewController {
      omiseAuthorizingPaymentController.delegate = self
      omiseAuthorizingPaymentController.authorizedURL = authorizedURL
      omiseAuthorizingPaymentController.expectedReturnURLPatterns =  [ URLComponents(string: "http://www.example.com/orders")! ]
  }
}
```

#### Receive `Authorizing Payment` events via the delegate
`OmiseAuthorizingPaymentViewController` send `Authorizing Payment` events to its `delegate` when there's an event occurred.

```swift
extension ViewController: OmiseAuthorizingPaymentViewControllerDelegate {
  func omiseAuthorizingPaymentViewController(_ viewController: OmiseAuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
    // Handle the `redirected URL` here
  }

  func omiseAuthorizingPaymentViewControllerDidCancel(_ viewController: OmiseAuthorizingPaymentViewController) {
    // Handle the case that user tap cancel button.
  }
}
```



## Contributing

Pull requests and bugfixes are welcome. For larger scope of work, please pop on to our [forum](https://forum.omise.co) to discuss first.

## LICENSE

MIT [See the full license text](https://github.com/omise/omise-ios/blob/master/LICENSE)

