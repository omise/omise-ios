
# Opn Payments iOS SDK

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Packager%20Manager-compatible-brightgreen?style=flat-square)](https://swift.org/package-manager)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@opn.ooo)
![CI](https://github.com/omise/omise-ios/workflows/CI/badge.svg?branch=master)

[Opn Payments](https://docs.opn.ooo/) is a payment service provider operating
in Thailand, Japan, and Singapore. Opn Payments provides a set of APIs that
help merchants of any size accept payments online.

The Opn Payments iOS SDK provides bindings for
[tokenizing credit cards](https://docs.opn.ooo/tokens-api) and
[accepting non-credit-card payments](https://docs.opn.ooo/sources-api)
using the Opn Payments API allowing developers to safely and easily accept
payments within apps.

If you run into any issues regarding this SDK and the functionality it
provides, consult the frequently asked questions in our
[comprehensive support documents](https://docs.opn.ooo/support).  If
you can't find an answer there, feel free to
[email our support team](mailto:support@opn.ooo).

## Requirements

* Opn Payments API public key. [Register for an Opn Payments account](https://dashboard.omise.co/signup) to obtain your API keys.
* iOS 10 or higher deployment target.
* Xcode 10.2 or higher (Xcode 12 is recommended)
* Swift 5.0 or higher (Swift 5.3 is recommended)

## Merchant compliance

**Card data should never transit through your server. We recommend that you follow our
guide on how to safely
[collect credit information](https://docs.opn.ooo/collecting-card-information).**

To be authorized to create tokens on your own server, you must have a
currently valid PCI-DSS Attestation of Compliance (AoC) delivered by a
certified QSA Auditor.  This SDK provides the means to tokenize card data
through the end user's mobile phone without this data having to go
through your server.

## Installation

To integrate the Opn Payments SDK into your Xcode project using the [Swift Package Manager](https://swift.org/package-manager/), proceed with the following steps:

1. In Xcode, select `File` > `Swift Packages` > `Add Package Dependency...`
2. Enter the URL for this repository `https://github.com/omise/omise-ios.git`
3. Choose a minimum semantic version of `v4.22.0`
4. Select your target, go to `Frameworks, Libraries, and Embedded Content` and set OmiseSDK to `Embed & Sign`

## Usage

If you cloned this project to your local hard drive, you can also
checkout the `QuickStart.playground`. Otherwise if you'd like all the
details, read on:

### Opn Payments API

The Opn Payments iOS SDK provides an easy-to-use library for calling the
Opn Payments API. The main class for the Opn Payments iOS SDK is `Client` through
which all requests to the Opn Payments API will be sent. Creating a new
`Client` object requires an Opn Payments public key.

``` swift
import OmiseSDK

let client = OmiseSDK.Client.init(publicKey: "omise_public_key")
```


The SDK currently
supports 2 main categories of requests: **Tokenizing a 
Card** and **Creating a Payment Source**.

#### Creating a card token

Normally, merchants must not send credit or debit card data to their own
servers. To collect a card payment from a
customer, merchants will need to first *tokenize* the card data using the
Opn Payments API and then use the generated token in place of the card
data. You can tokenize card data by creating and initializing
a `Request<Token>` as follows:

```swift
let tokenParameters = Token.CreateParameter(
    name: "JOHN DOE",
    number: "4242424242424242",
    expirationMonth: 11,
    expirationYear: 2022,
    securityCode: "123"
)

let request = Request<Token>(parameter: tokenParameters)
```

#### Creating a payment source

Opn Payments now supports many payment methods other than cards.  You
may request a payment with one of those supported payment methods from
a customer by calling the `CreateSourceParameter` API. You need to specify
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

#### Sending the request

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

A simple completion handler for a token looks as follows.

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

### Built-in forms

Opn Payments iOS SDK provides easy-to-use drop-in UI forms for both Tokenizing a Card and Creating a Payment Source, which
you can easily integrate into your application.

#### Card form

The `CreditCardFormViewController` provides a pre-made card form and will automatically
[tokenize card information](https://docs.opn.ooo/security-best-practices) for you.
You only need to implement two delegate methods and a way to display the form.

##### Use card form in code

To use the controller in your application, modify your view controller with the following additions:

```swift
import OmiseSDK // at the top of the file

class ViewController: UIViewController {
  private let publicKey = "pkey_test_123"

  @IBAction func displayCreditCardForm() {
    let creditCardView = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
    creditCardView.delegate = self
    creditCardView.handleErrors = true

    present(creditCardView, animated: true, completion: nil)
  }
}
```

Then implement the delegate to receive the `Token` object after user has entered the card data:

```swift
extension ViewController: CreditCardFormViewControllerDelegate {
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

Alternatively, you can also push the view controller onto a `UINavigationController` stack
as follows:

```swift
@IBAction func displayCreditCardForm() {
  let creditCardView = CreditCardFormViewController.makeCreditCardFormViewController(publicKey)
  creditCardView.delegate = self
  creditCardView.handleErrors = true

  // This View Controller is already in a UINavigationController stack
  show(creditCardView, sender: self)
}
```

##### Use card form in storyboard

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

##### Custom card form

You can create your own card form if you want but please keep in mind that you must not send the card information to your server.
Opn Payments iOS SDK provides some built-in card UI components to make it easier to create your own card form:

* `CardNumberTextField` - Provides basic number grouping as the user types.
* `CardNameTextField` - Cardholder name field.
* `CardExpiryDateTextField` - Provides card expiration date input and styling
* `CardExpiryDatePicker` - `UIPickerView` implementation that has a month and year column.
* `CardCVVTextField` - CVV number field.

Additionally, fields turn red automatically if their content fails
basic validation (e.g. alphabetic characters in the number field,
content with wrong length, etc.) and come in two supported styles, plain
and border.

#### Built-in payment creator controller

The `PaymentCreatorController` provides a pre-made form to let a customer choose how they want to make a payment.
Please note that the `PaymentCreatorController` is designed to be used as-is. It is a subclass of `UINavigationController`
and you shouldn't push your view controllers into its navigation controller stack.
You can configure it to display either specified payment method options or a default list based on your country.

##### Use payment creator controller in code
You can create a new instance of `PaymentCreatorController` by calling its factory method:

```swift

let allowedPaymentMethods = PaymentCreatorController.thailandDefaultAvailableSourceMethods

let paymentCreatorController = PaymentCreatorController.makePaymentCreatorControllerWith(
  publicKey: publicKey,
  amount: paymentAmount,
  currency: Currency(code: paymentCurrencyCode),
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
##### Use payment creator controller in storyboard
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

### Authorizing payment

Some payment methods require the customers to authorize the payment via an authorized URL. This includes [3-D Secure verification](https://docs.opn.ooo/fraud-protection#3-d-secure), [Internet Banking payment](https://docs.opn.ooo/internet-banking), [Alipay](https://docs.opn.ooo/alipay). The Opn Payments iOS SDK provides a built-in class to authorize payments.

On payment methods that require opening the external application (e.g. mobile banking application) to authorize the transaction, set the *return_uri* to a **deeplink** or **applink** to be able to open the merchant application. Else, after the card holder completes authorizing the transaction on the external application, the flow redirects to the normal link in the *return_uri* and opens it on the browser application, and therefore results in the payment not being completed.

#### Using built-in authorizing payment view controller

You can use the built-in authorizing payment view controller by creating an instance of `OmiseAuthorizingPaymentViewController`, and setting it with `authorized URL` provided with the charge and expected `return URL` patterns that you create.

##### Create an `OmiseAuthorizingPaymentViewController` by code

You can create an instance of `OmiseAuthorizingPaymentViewController` by calling its factory method
```swift
let handlerController = OmiseAuthorizingPaymentViewController.makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
self.present(handlerController, animated: true, completion: nil)
```

##### Use `OmiseAuthorizingPaymentViewController` in storyboard

`OmiseAuthorizingPaymentViewController` also comes with built-in storyboard support such as `CreditCardFormViewController`. You can use `OmiseAuthorizingPaymentViewController` in your storyboard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas, set its bundle identifier to `co.omise.OmiseSDK` and storyboard to `OmiseSDK`, then use `DefaultAuthorizingPaymentViewController` as a `Referenced ID`.
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

`OmiseAuthorizingPaymentViewController` sends `Authorizing Payment` events to its `delegate` when an event occurs.

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

## Objective-C compatibility

Opn Payments iOS SDK comes with full Objective-C support. The SDK is designed with the Swift language as a first-class citizen, and not only adopts Swift-only features in the SDK, but also provides an Objective-C counterpart for those features.
If you found an API that is not available in Objective-C, please don't hestitate [to open an issue](https://github.com/omise/omise-ios/issues/new).


## Contributing

Pull requests, issues, and bugfixes are welcome!

## License

MIT [See the full license text](https://github.com/omise/omise-ios/blob/master/LICENSE)
