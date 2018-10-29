# Omise iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@omise.co)
[![](https://img.shields.io/badge/discourse-forum-1a53f0.svg?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAqlJREFUKBU9UVtLVFEU%2FvY%2B27mPtxl1dG7HbNRx0rwgFhJBPohBL9JTZfRQ0YO9RU%2FVL6iHCIKelaCXqIewl4gEBbEyxSGxzKkR8TbemmbmnDlzVvsYtOHbey1Y317fWh8DwCVMCfSHww3ElCs7CjuzbOcNIaEo9SbtlDRjZiNPY%2BvrqSWrTh7l3yPvrmh0KBZW59HcREjEqcGpElAuESRxopU648dTwfrIyH%2BCFXSH1cFgJLqHlma6443SG0CfqYY2NZjQnkV8eiMgP6ijjnizHglErlocdl5VA0mT3v102dseL2W14cYM99%2B9XGY%2FlQArd8Mo6JhbSJUePHytvf2UdnW0qen93cKQ4nWXX1%2FyOkZufsuZN0L7PPzkthDDZ4FQLajSA6XWR8HWIK861sCfj68ggGwl83mzfMclBmAQ%2BktrqBu9wOhcD%2BB0ErSiFFyEkdcYhKD27mal9%2F5FY36b4BB%2FTvO8XdQhlUe11F3WG2fc7QLlC8wai3MGGQCGDkcZQyymCqAPSmati3s45ygWseeqADwuWS%2F3wGS5hClDMMstxvJFHQuGU26yHsY6iHtL0sIaOyZzB9hZz0hHZW71kySSl6LIJlSgj5s5LO6VG53aFgpOfOFCyoFmYsOS5HZIaxVwKYsLSbJJn2kfU%2BlNdms5WMLqQRklX0FX26eFRnKYwzX0XRsgR0uUrWxplM7oqPIq8r8cZrdLNLqaABayxZMTTx2HVfglbP4xkcvqZEMNfmglevRi1ny5mGfJfTuQiBEq%2FMBvG0NqDh2TY47sbtJAuO%2Fe9%2Fn3STRFosm2WIxsFSFrFUfwHb11JNBNcaZSp8yb%2FEhHW3suWRNZRzDGvxb0oifk5lmnX2V2J2dEJkX1Q0baZ1MvYXPXHvhAga7x9PTEyj8a%2BF%2BXbxiTn78bSQAAAABJRU5ErkJggg%3D%3D)](https://forum.omise.co)


Omise is a payment service provider currently operating in Thailand. Omise provides a set
of clean APIs that helps merchants of any size accept credit cards online.

Omise iOS SDK provides bindings for the Omise
[Tokenization](https://www.omise.co/tokens-api) and [Source](https://www.omise.co/sources-api) APIs so you do not need to pass credit card
data to your server as well as components for entering credit card information.

Hop into our forum (click the badge above) or email our support team if you have any
question regarding this SDK and the functionality it provides.

## Requirements

* Public key. [Register for an Omise account](https://dashboard.omise.co/signup) to obtain your API keys.
* iOS 8 or higher deployment target.
* Xcode 9.0 or higher (Xcode 10 is recommended)
* Swift 4.0 or higher (Swift 4.2 is recommended)
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
github "omise/omise-ios" ~> 3.0
```

And run `carthage bootstrap` or `carthage build` Or run this copy-pastable script for a
quick start:

```
echo 'github "omise/omise-ios" ~> 3.0’ >> Cartfile; carthage bootstrap
```

## Usage

If you clone this project to your local hard drive, you can also checkout the `QuickStart`
playground. Otherwise if you'd like all the details, read on:

### Omise API Call

Omise iOS SDK provides an easy to use library for calling to the Omise API. The main class for Omise iOS SDK is the `Client` class.
You will request to Omise API by sending a request though this class. The `Client` object requires an Omise Public Key. We have 2 main categories of the requests. 

#### Credit Card Tokenization

Normally, merchants must not send a credit card data to their own servers. In order to collect a credit card payment from a customer,
merchants will tokenize the credit card data with Omise API first and then use the generated token instead. 
You can tokenize a credit card data by first creating and initializing a `Request<Token>` like so:

```swift
let tokenParameter = Source.CreateParameter(
    name: "JOHN DOE",
    number: "4242424242424242",
    expirationMonth: 11,
    expirationYear: 2019,
    securityCode: "123"
)
let request = Request<Token>(parameter: tokenParameter)
```

Then create a request task on a `Client` with the completion handler block and call `resume` on the RequestTask:

```swift
let requestTask = client.requestTask(with: request, completionHandler: completionHandler)
requestTask.resume()
```


You may also send a request by calling the `send(_:completionHandler:)` method on the `Client`.

```swift
client.send(request) { [weak self] (result) in
  guard let s = self else { return }

  // switch result { }
}
```

#### Payment Source

Omise supports many payment mothods other than `Credit Card`. 
You may request a payment with one of those supported payment methods from a customer via a `Source` API.

#### Create a Source Request

You can create a new Source object by calling Create Source API. You need to specify the parameter of a Source you want to create
by creating and initializeing a `Request<Source>` with the `Payment Information` object:

```swift
let paymentInformation = PaymentInformation.internetBanking(.bbl) // Bangkok Bank Internet Banking payment method
let sourceParameter = CreateSourceParameter(
    paymentInformation: paymentInformation,
    amount: amount, currency: currency)
)
```
Then create a request task on a `Client` with the completion handler block and call `resume` on the RequestTask, similar to credit card tokenization:

```swift
let requestTask = client.requestTask(with: request, completionHandler: completionHandler)
requestTask.resume()
```


### Built-in Forms

Omise iOS SDK provides built-in easy to use drop-in UI forms for both `Credit Card Tokenization` and `Create a Payment Source`.
You can easily integrate those forms into your app with minimum effort to set up the form.


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
`CreditCardFormViewController` comes with built in storyboard support. You can use `CreditCardFormViewController` in your storybard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK`. You can either leave `Referenced ID` empty or use `CreditCardFormController` as a `Referenced ID`
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

You can create your own Credit Card form if you want to but please keep in mind that you must not send the Credit Card information to your server.
Omise iOS SDK provides some built-in credit card UI compoments to help creating your own Credit Card form easier:

* `CardNumberTextField` - Provides basic number grouping as the user types.
* `CardNameTextField`
* `CardExpiryDateTextField` - Provids card expiration date input and styling
* `CardExpiryDatePicker` - `UIPickerView` implementation that have a month and year
  column.
* `CardCVVTextField` - CVV number field.

Additionally fields also turns red automatically if their content fails basic validation
(e.g. alphabets in number field, or content with wrong length) and come in 2 supported styles, plain and border



#### Built-in Payment Creator Controller

The `PaymentCreatorController` provides a pre-made form to let a customer choose how they want to make a payment.
Please note that the PaymentCreatorController is designed to be used as is. It is a subclass of `UINavigationController` 
and you shouldn't push your view controllers into its navigation controller stack.
You can configure it to display specified Payment Method options as you want or the default list based on the your country. 

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
`PaymentCreatorController` comes with built in storyboard support. 
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
Some payment method require the customers to authorize the payment via an authorized URL. This includes the [3-D Secure verification](https://www.omise.co/fraud-protection#3-d-secure), [Internet Banking payment](https://www.omise.co/offsite-payment), [Alipay](https://www.omise.co/alipay) and etc. Omise iOS SDK provide a built in class to do the authorization.

#### Using built in Authorizing Payment view controller
You can use the built in Authorizing Payment view controller by creating an instance of `OmiseAuthorizingPaymentViewController` and set it with `authorized URL` given with the charge and expected `return URL` patterns those were created by merchants.

##### Create an `OmiseAuthorizingPaymentViewController` by code
You can create an instance of `OmiseAuthorizingPaymentViewController` by calling its factory method
```swift
let handlerController = OmiseAuthorizingPaymentViewController.makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
self.present(handlerController, animated: true, completion: nil)
```

##### Use `OmiseAuthorizingPaymentViewController` in Storyboard
`OmiseAuthorizingPaymentViewController` also comes with built in storyboard support like `CreditCardFormViewController`. You can use `OmiseAuthorizingPaymentViewController` in your storyboard by using `Storyboard Reference`. Drag `Storyboard Reference` object onto your canvas and set its bundle identifier to `co.omise.OmiseSDK` and Storyboard to `OmiseSDK` then use `DefaultAuthorizingPaymentViewController` as a `Referenced ID`.
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

## Objective-C compatability

Omise iOS SDK comes with fully Objective-C support. You can call every APIs of this SDK in Objective-C. 
Even though this SDK is designed with the Swift language as a first class citizen and adopts Swift only features in the SDK, the SDK also provides the Objective-C counterpart for those.
If you found an API that is not availabe in Objective-C, please don't hestitate to open an issue.

## Migration Note

Omise iOS SDK provides the compatibilty classes to help developers migrate the current code base that based on the Omise iOS SDK version 2 to the new version 3.
Developer shouldn't put much effort to upgrade the code base. The compiler should warn you to rename/change your code to the new API and provide you a `fix-it` popup for that.
However, there are a few exceptions where the SDK and compiler cannot give developer the rename fix-its due to the limitation in either Swift or compiler itself especially in the Objective-C code base. 
We worked with the Swift Open Source Project to fix issues related to Objective-C headers. The fix would be in Swift 5 compiler.  

If you have any question or problem, please feel free to ask in our [forum](https://forum.omise.co)

## Contributing

Pull requests and bugfixes are welcome. For larger scope of work, please pop on to our [forum](https://forum.omise.co) to discuss first.

## LICENSE

MIT [See the full license text](https://github.com/omise/omise-ios/blob/master/LICENSE)

