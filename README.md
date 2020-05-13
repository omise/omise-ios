[![Omise](https://cdn.omise.co/assets/omise.png)](https://omise.co)

# Omise iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@omise.co)
[![](https://img.shields.io/badge/discourse-forum-1a53f0.svg?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAqlJREFUKBU9UVtLVFEU%2FvY%2B27mPtxl1dG7HbNRx0rwgFhJBPohBL9JTZfRQ0YO9RU%2FVL6iHCIKelaCXqIewl4gEBbEyxSGxzKkR8TbemmbmnDlzVvsYtOHbey1Y317fWh8DwCVMCfSHww3ElCs7CjuzbOcNIaEo9SbtlDRjZiNPY%2BvrqSWrTh7l3yPvrmh0KBZW59HcREjEqcGpElAuESRxopU648dTwfrIyH%2BCFXSH1cFgJLqHlma6443SG0CfqYY2NZjQnkV8eiMgP6ijjnizHglErlocdl5VA0mT3v102dseL2W14cYM99%2B9XGY%2FlQArd8Mo6JhbSJUePHytvf2UdnW0qen93cKQ4nWXX1%2FyOkZufsuZN0L7PPzkthDDZ4FQLajSA6XWR8HWIK861sCfj68ggGwl83mzfMclBmAQ%2BktrqBu9wOhcD%2BB0ErSiFFyEkdcYhKD27mal9%2F5FY36b4BB%2FTvO8XdQhlUe11F3WG2fc7QLlC8wai3MGGQCGDkcZQyymCqAPSmati3s45ygWseeqADwuWS%2F3wGS5hClDMMstxvJFHQuGU26yHsY6iHtL0sIaOyZzB9hZz0hHZW71kySSl6LIJlSgj5s5LO6VG53aFgpOfOFCyoFmYsOS5HZIaxVwKYsLSbJJn2kfU%2BlNdms5WMLqQRklX0FX26eFRnKYwzX0XRsgR0uUrWxplM7oqPIq8r8cZrdLNLqaABayxZMTTx2HVfglbP4xkcvqZEMNfmglevRi1ny5mGfJfTuQiBEq%2FMBvG0NqDh2TY47sbtJAuO%2Fe9%2Fn3STRFosm2WIxsFSFrFUfwHb11JNBNcaZSp8yb%2FEhHW3suWRNZRzDGvxb0oifk5lmnX2V2J2dEJkX1Q0baZ1MvYXPXHvhAga7x9PTEyj8a%2BF%2BXbxiTn78bSQAAAABJRU5ErkJggg%3D%3D)](https://forum.omise.co)

[Omise](https://www.omise.co/) is a payment service provider operating
in Thailand, Japan, and Singapore. Omise provides a set of APIs that
help merchants of any size accept payments online.

The Omise iOS SDK provides bindings for
[tokenizing credit cards](https://www.omise.co/tokens-api) and
[accepting non-credit-card payments](https://www.omise.co/sources-api)
using the Omise API allowing developers to safely and easily accept
payments within apps.

If you run into any issues regarding this SDK and the functionality it
provides, consult the frequently asked questions in our
[comprehensive support documents](https://www.omise.co/support).  If
you can't find an answer there, post a question in our
[forum](https://forum.omise.co/c/development) or feel free to
[email our support team](mailto:support@omise.co).

## Requirements

* Omise API public key. [Register for an Omise account](https://dashboard.omise.co/signup) to obtain your API keys.
* iOS 8 or higher deployment target.
* Xcode 10.0 or higher (Xcode 11 is recommended)
* Swift 5.0 or higher (Swift 5.1 is recommended)
* [Carthage](https://github.com/Carthage/Carthage) dependency manager.

## Merchant Compliance

**Card data should never transit through your server. We recommend that you follow our
guide on how to safely
[collect credit information](https://www.omise.co/collecting-card-information).**

To be authorized to create tokens on your own server, you must have a
currently valid PCI-DSS Attestation of Compliance (AoC) delivered by a
certified QSA Auditor.  This SDK provides means to tokenize card data
through the end user's mobile phone without this data having to go
through your server.

## Installation

To get started, add the following line to your `Cartfile`:

```
github "omise/omise-ios" ~> 3.0
```

Then run `carthage update`:

``` bash
$ carthage update
*** Fetching omise-ios
*** Checking out omise-ios at "v3.5.0"
*** xcodebuild output can be found in /var/folders/sd/ccsbmstn2vbbqd7nk4fgkd040000gn/T/carthage-xcodebuild.X7ZfYB.log
*** Building scheme "OmiseSDK" in OmiseSDK.xcodeproj
```

## Usage

If you cloned this project to your local hard drive, you can also
checkout the `QuickStart.playground`. Otherwise if you'd like all the
details, read on:

### Omise API

The Omise iOS SDK provides an easy-to-use library for calling the
Omise API. The main class for the Omise iOS SDK is `Client` through
which all requests to the Omise API will be sent. Creating a new
`Client` object requires an Omise public key.

``` swift
import OmiseSDK

let client = OmiseSDK.Client.init(publicKey: "omise_public_key")
```


The SDK currently
supports 2 main categories of the requests: **Tokenizing a Credit
Card** and **Creating a Payment Source**.

#### Creating a Card Token

Normally, merchants must not send credit or debit card data to their own
servers. So, in order to collect a credit card payment from a
customer, merchants will need to *tokenize* the credit card data using
Omise API first and then use the generated token in place of the card
data.  You can tokenize credit card data by creating and initializing
a `Request<Token>` like so:

```swift
let tokenParameters = Token.CreateParameter(
    name: "JOHN DOE",
    number: "4242424242424242",
    expirationMonth: 11,
    expirationYear: 2019,
    securityCode: "123"
)

let request = Request<Token>(parameter: tokenParameters)
```

#### Creating a Payment Source

Omise now supports many payment methods other than credit cards.  You
may request a payment with one of those supported payment methods from
a customer by calling `CreateSourceParameter` API. You need to specify
the parameters (e.g. payment amount and currency) of the source you
want to create by creating and initializing a `Request<Source>` with
the `Payment Information` object:

```swift
let paymentInformation = PaymentInformation.internetBanking(.bbl) // Bangkok Bank Internet Banking payment method
let sourceParameter = CreateSourceParameter(
    paymentInformation: paymentInformation,
    amount: amount,
    currency: currency
)

let request = Request<Source>(parameter: sourceParameter)
```

#### Sending the Request

Whether you are charging a source or a card, sending the
request is the same.  Create a new `requestTask` on a `Client` object
with the completion handler block and call `resume` on the
requestTask:

```swift
let requestTask = client.requestTask(with: request, completionHandler: completionHandler)
requestTask.resume()
```

You may also send a request by calling the
`send(_:completionHandler:)` method on the `Client`.

```swift
client.send(request) { [weak self] (result) in
  guard let s = self else { return }

  // switch result { }
}
```

#### Creating the completion handler

A simple completion handler for a token looks like this.

``` swift
func completionHandler(tokenResult: Result<Token, Error>) -> Void {
    switch tokenResult {
    case .success(let value):
        // do something with Token id
        print(value.id)
    case .failure(let error):
        print(error)
    }
}
```

### Built-in Forms

Omise iOS SDK provides easy-to-use drop-in UI forms for both Tokenizing a Credit Card and Creating a Payment Source which
you can easily integrate into your app.

#### Credit Card Form

The `CreditCardFormViewController` provides a pre-made credit card form and will automatically
[tokenize credit card information](https://www.omise.co/security-best-practices) for you.
You only need to implement two delegate methods and a way to display the form.

##### Use Credit Card Form in code

To use the controller in your application, modify your view controller with the following additions:

```swift
import OmiseSDK // at the top of the file

class ViewController: UIViewController {
  private let publicKey = "pkey_test_123"

  @IBAction func displayCreditCardForm() {
    let creditCardView = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
    creditCardView.delegate = self
    creditCardView.handleErrors = true

	present(navigation, animated: true, completion: nil)
  }
}
```

Then implement the delegate to receive the `Token` object after user has entered the
credit card data:

```swift
extension ViewController: CreditCardFormDelegate {
  func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
    dismissCreditCardForm()

    // Sends `Token` to your server to create a charge, or a customer object.
  }

  func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
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
  let creditCardView = CreditCardFormViewController.makeCreditCardFormViewController(publicKey)
  creditCardView.delegate = self
  creditCardView.handleErrors = true

  // This View Controller is already in a UINavigationController stack
  show(creditCardView, sender: self)
}
```

##### Use Credit Card Form in Storyboard

`CreditCardFormViewController` comes with built-in storyboard support. You can use `CreditCardFormViewController` in your storybard by using `Storyboard Reference`. Drag the `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK`. You can either leave `Referenced ID` empty or use `CreditCardFormController` as a `Referenced ID`
You can setup `CreditCardFormViewController` in `UIViewController.prepare(for:sender:)` method

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  if segue.identifier == "PresentCreditFormWithModal",
    let creditCardFormNavigationController = segue.destination as? UINavigationController,
    let creditCardFormViewController = creditCardFormNavigationController.topViewController as? CreditCardFormViewController {
      creditCardFormViewController.publicKey = publicKey
      creditCardFormViewController.handleErrors = true
      creditCardFormViewController.delegate = self
  }
}
```

##### Custom Credit Card Form

You can create your own credit card form if you want to but please keep in mind that you must not send the credit card information to your server.
Omise iOS SDK provides some built-in credit card UI components to make it easier to create your own credit card form:

* `CardNumberTextField` - Provides basic number grouping as the user types.
* `CardNameTextField`
* `CardExpiryDateTextField` - Provides card expiration date input and styling
* `CardExpiryDatePicker` - `UIPickerView` implementation that has a month and year column.
* `CardCVVTextField` - CVV number field.

Additionally fields turn red automatically if their content fails
basic validation (e.g. alphabetic characters in the number field,
content with wrong length, etc.) and come in 2 supported styles, plain
and border.

#### Built-in Payment Creator Controller

The `PaymentCreatorController` provides a pre-made form to let a customer choose how they want to make a payment.
Please note that the `PaymentCreatorController` is designed to be used as-is. It is a subclass of `UINavigationController`
and you shouldn't push your view controllers into its navigation controller stack.
You can configure it to display either specified payment method options or a default list based on your country.

##### Use Payment Creator Controller in code
You can create a new instance of `PaymentCreatorController` by calling its factory method:

```swift

let allowedPaymentMethods = PaymentCreatorController.thailandDefaultAvailableSourceMethods

let paymentCreatorController = PaymentCreatorController.makePaymentCreatorControllerWith(
  publicKey: publicKey,
  amount: paymentAmount, currency: Currency(code: paymentCurrencyCode),
  allowedPaymentMethods: allowedPaymentMethods,
  paymentDelegate: self
)
present(paymentCreatorController, animated: true, completion: nil)
```

Then implement the delegate to receive the `Payment` object after user has selected:

```swift
extension ProductDetailViewController: PaymentCreatorControllerDelegate {
  func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment) {
    dismissForm()

    // Sends selected `Token` or `Source` to your server to create a charge, or a customer object.
  }

  func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error) {
    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(okAction)
    paymentCreatorController.present(alertController, animated: true, completion: nil)

    // Only important if we set `handleErrors = false`.
    // You can send errors to a logging service, or display them to the user here.
  }

  func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController) {
  	dismissForm()
  }
}
```
##### Use Payment Creator Controller in Storyboard
`PaymentCreatorController` comes with built-in storyboard support.
You can use `PaymentCreatorController` in your storybard by using `Storyboard Reference`.
Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK`
and  `PaymentCreatorController` as a `Referenced ID`
You can setup `PaymentCreatorController` in `UIViewController.prepare(for:sender:)` method

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  if segue.identifier == "PresentCreditFormWithModal",
  let paymentCreatorController = segue.destination as? UINavigationController {
    paymentCreatorController.publicKey = self.publicKey
    paymentCreatorController.paymentAmount = paymentAmount
    paymentCreatorController.paymentCurrency = paymentCurrency
    paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
    paymentCreatorController.paymentDelegate = self
  }
}
```


### Authorizing Payment

Some payment methods require the customers to authorize the payment via an authorized URL. This includes the [3-D Secure verification](https://www.omise.co/fraud-protection#3-d-secure), [Internet Banking payment](https://www.omise.co/offsite-payment), [Alipay](https://www.omise.co/alipay). The Omise iOS SDK provides a built-in class to do the authorization.

#### Using built-in Authorizing Payment view controller

You can use the built-in Authorizing Payment view controller by creating an instance of `OmiseAuthorizingPaymentViewController` and set it with `authorized URL` given with the charge and expected `return URL` patterns those were created by merchants.

##### Create an `OmiseAuthorizingPaymentViewController` by code

You can create an instance of `OmiseAuthorizingPaymentViewController` by calling its factory method
```swift
let handlerController = OmiseAuthorizingPaymentViewController.makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
self.present(handlerController, animated: true, completion: nil)
```

##### Use `OmiseAuthorizingPaymentViewController` in Storyboard

`OmiseAuthorizingPaymentViewController` also comes with built-in storyboard support like `CreditCardFormViewController`. You can use `OmiseAuthorizingPaymentViewController` in your storyboard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK` then use `DefaultAuthorizingPaymentViewController` as a `Referenced ID`.
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

##### Receive `Authorizing Payment` events via the delegate

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

## Objective-C Compatibility

Omise iOS SDK comes with full Objective-C support. The SDK is designed with the Swift language as a first-class citizen and adopts Swift-only features in the SDK, but it also provides an Objective-C counterpart for those features.
If you found an API that is not available in Objective-C, please don't hestitate [to open an issue](https://github.com/omise/omise-ios/issues/new).

## Migration Note

The Omise iOS SDK provides compatibilty classes to help developers migrate their current code base based on Omise iOS SDK version 2 to the current version 3.
The intention is that developer shouldn't have to put much effort into upgrading their code base. The compiler should warn you to rename/change your code to the new API and provide "Fix-it" dialogs for that.
However, there are a few exceptions where the SDK and compiler cannot give developer automated "Fix-it" dialogs due to limitations in Swift or compiler itself especially in the Objective-C codebase.
We worked with the Swift Open Source Project to fix issues related to Objective-C headers. The fix should be in the Swift 5 compiler.

Omise SDK version 3.1.0 was migrated to adopt Swift 5.0 which introduces the official Result enum value type in Swift standard library.
Omise SDK has adopted the type and replace the existed RequestResult with it and Omise SDK provides the typealias cause which should help on the compatiblity.
However due to the Swift syntax limitation, Omise SDK couldn't provide the bridge for `fail` to `Swift.Result.failure` case in pattern matching statements.
The developer need to migrate this by themselves. We are sorry that this happened but we think this change will pay itself back in the future since the Swift.Result type would be a standard type for representing the Result of an operation.

If you have any questions or problems during your migration, please feel free to post a question in our [forum](https://forum.omise.co) or [email our support team](mailto:support@omise.co).

### Note on Version 2.7.0

We encourage merchants to adopt the 3.0.0 version since it introduced many new features including Source API and a built-in Payment Creator form.

To help merchants to adopt the 3.0.0 version, we decided to add version 2.7.0 which is the same one as 3.0.0 and remove the old versions from the releases.
The Omise iOS SDK version 3.0.0 comes with the great compatibility with the version 2 this means that merchants should have little work to migrate to the new version.
We believe this would help merchants in the long term.

We also highly recommend merchants to fully adopt Omise iOS SDK version 3 to receive the new update in the future.


## Contributing

Pull requests, issues, and bugfixes are welcome! For larger changes, please pop on to our [forum](https://forum.omise.co) to discuss first.

## LICENSE

MIT [See the full license text](https://github.com/omise/omise-ios/blob/master/LICENSE)
