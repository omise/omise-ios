
# Omise iOS SDK

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Packager%20Manager-compatible-brightgreen?style=flat-square)](https://swift.org/package-manager)
[![](https://img.shields.io/badge/email-support-yellow.svg?style=flat-square)](mailto:support@omise.co)
![CI](https://github.com/omise/omise-ios/workflows/CI/badge.svg?branch=master)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fomise%2Fomise-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/omise/omise-ios)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fomise%2Fomise-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/omise/omise-ios)

[Omise](https://docs.omise.co/) is a payment service provider operating
in Thailand, Japan, and Singapore. Omise provides a set of APIs that
help merchants of any size accept payments online.

The Omise iOS SDK provides bindings for
[tokenizing credit cards](https://docs.omise.co/tokens-api) and
[accepting non-credit-card payments](https://docs.omise.co/sources-api)
using the Omise API, allowing developers to safely and easily accept
payments within apps.

If you run into any issues regarding this SDK and the functionality it
provides, consult the frequently asked questions in our
[comprehensive support documents](https://docs.omise.co/support).  If
you can't find an answer there, feel free to
[email our support team](mailto:support@omise.co).

## Security Warning

**Please do NOT use Omise iOS SDK versions less than 3.2.0, as they are outdated and have security vulnerabilities.**


## Requirements

* Omise API public key. [Register for an Omise account](https://dashboard.omise.co/signup) to obtain your API keys.
* iOS 14 or higher deployment target.
* Xcode 15.0 or higher (Xcode 26 is recommended)
* Swift 5.0 or higher (Swift 5.3 is recommended)

## Merchant compliance

**Card data should never transit through your server. We recommend that you follow our
guide on how to safely
[collect credit information](https://docs.omise.co/collecting-card-information).**

To be authorized to create tokens on your server, you must have a
currently valid PCI-DSS Attestation of Compliance (AoC) delivered by a
certified QSA Auditor.  This SDK provides the means to tokenize card data
through the end user's mobile phone without this data having to go
through your server.

## Installation

To integrate the Omise SDK into your Xcode project using the [Swift Package Manager](https://swift.org/package-manager/), proceed with the following steps:

1. In Xcode, select `File` > `Swift Packages` > `Add Package Dependency...`
2. Enter the URL for this repository `https://github.com/omise/omise-ios.git`
3. Choose the latest available `5.6.0` release
4. Select your target, go to `Frameworks, Libraries, and Embedded Content`, and set OmiseSDK to `Embed & Sign`

## Usage

The Omise iOS SDK provides an easy-to-use library for calling the
Omise API and presenting UI forms.

The main class and protocol for the Omise iOS SDK are `OmiseSDK` and `ClientProtocol` through
which all requests to the Omise API will be sent.

To start working with OmiseSDK, you must create a new instance of the `OmiseSDK` class with an Omise public key.

```swift
import OmiseSDK

let omiseSDK = OmiseSDK(publicKey: "omise_public_key")
```

You can also set up and use a `shared` instance of `OmiseSDK` in your code:
```swift
OmiseSDK.shared = omiseSDK
```


If you cloned this project to your local hard drive, you can check out `ExampleApp.xcodeproj`.

#### ApplePay
To enable Apple Pay in your app, configure your Apple Pay Merchant Identifier using the setupApplePay method.
Refer to the ExampleApp sample for a complete implementation.
For more information, please review at [Omise Apple Pay Documentation](https://docs.omise.co/applepay/singapore).

```swift 
omiseSDK.setupApplePay(for: "your_merchant_id", requiredBillingAddress: true)
```
Replace "your_merchant_id" with your actual Apple Pay Merchant Identifier.


### Omise API

The SDK currently
supports two main categories of requests: **Tokenizing a 
Card** and **Creating a Payment Source**.

#### Creating a card token

Normally, merchants must not send credit or debit card data to their own
servers. To collect a card payment from a
customer, merchants must first *tokenize* the card data using the
Omise API and then use the generated token in place of the card
data. You can tokenize card data by creating and initializing
a `CreateTokenPayload.Card` as follows:

```swift
let createTokenPayload = CreateTokenPayload.Card(
    name: "JOHN DOE",
    number: "4242424242424242",
    expirationMonth: 11,
    expirationYear: 2022,
    securityCode: "123"
)

let createTokenPayloadWithAddress = CreateTokenPayload.Card(
    name: "JOHN DOE",
    number: "4242424242424242",
    expirationMonth: 11,
    expirationYear: 2022,
    securityCode: "123",
    phoneNumber: "0123456789",
    countryCode: "TH",
    city: "Bangkok",
    state: "Bangkok",
    street1: "Sukhumvit",
    street2: "",
    postalCode: "10110"
)
```

#### Creating a payment source

Omise supports many payment methods other than cards. You
may request a payment with one of those supported payment methods from
a customer by calling the `CreateSource` API. You need to specify
the parameters (e.g., payment amount and currency) of the source you
want to create by creating and initializing a `CreateSourcePayload` with
the `Payment Information` object:

```swift
let createSourcePayload = CreateSourcePayload(
    amount: amount,
    currency: currency,
    details: .sourceType(.internetBankingBBL) // Bangkok Bank Internet Banking payment method
)
```

After creating the token or the payment source, create the completion handler, as follows:

#### Creating the completion handler

A simple completion handler for a token, for example, is as follows:

```swift
func tokenCompletionHandler(tokenResult: Result<Token, Error>) -> Void {
    switch tokenResult {
    case .success(let token):
        // do something with Token id
        print(token.id)
    case .failure(let error):
        print(error)
    }
}
```

Now, send the request:

#### Sending the request

Whether you are charging a source or a card, sending the
request is the same.  Use the `ClientProtocol` to perform one-off API calls
with the completion handler block.

```swift
let client = omiseSDK.client
client.createToken(payload: createTokenPayload, tokenCompletionHandler)
client.createSource(payload: createSourcePayload, sourceCompletionHandler)
client.capability(capabilityCompletionHandler)
client.token(tokenID: "tokenID", tokenInfoCompletionHandler)
client.observeChargeStatus(chargeStatusCompletionHandler)
```

### Using built-in forms

Omise iOS SDK provides easy-to-use drop-in UI forms for both Tokenizing a Card and Creating a Payment Source, which
you can easily integrate into your application.

#### Card form

The `omiseSDK.presentCreditCardPayment()` provides a pre-made card form that will automatically
[tokenize card information](https://docs.omise.co/security-best-practices) for you.

##### Use Omise card form

To use the controller in your application, modify your view controller with the following additions:

```swift
import OmiseSDK

class ViewController: UIViewController {
  private let omiseSDK = OmiseSDK("pkey_test_123")

  @IBAction func displayCreditCardPayment() {
    omiseSDK.presentCreditCardPayment(from: self, delegate: self)
  }
}
```

You can provide extra parameters:
- `countryCode` to preselect the country in the UI form 
- `handleErrors` to process and display errors (by default, is `true`); if `false`, then the delegate 
method `choosePaymentMethodDidComplete(with error: Error)` will be called instead.

```swift
omiseSDK.presentCreditCardPayment(
  from: self,
  countryCode: "TH", // if `nil` it will use country from Capability API 
  handleErrors: true,  // by default `true`
  delegate: self
)
```
    
Then implement the delegate to receive the `Token` object after the user has entered the card data:

```swift
extension ViewController: ChoosePaymentMethodDelegate {
  func choosePaymentMethodDidComplete(with token: Token) {
    // Send `Token` to your server to create a charge or a customer object.
    print(token.id) // prints Token ID
  }

  func choosePaymentMethodDidComplete(with error: Error) {
    // Only called if we set `handleErrors = false`.
    // You can send errors to a logging service or display them here to the user.
  }
}
```

You can call `OmiseSDK.dismiss(animated:completion:)` to close UI form presented by OmiseSDK:

```swift
  func choosePaymentMethodDidComplete(with token: Token) {
    omiseSDK.dismiss {
      // present another screen 
    }
  }

``` 

##### Creating a custom card form

You can create your card form, but please remember you must not send the card information to your server.
Omise iOS SDK provides the following built-in card UI components to make it easier to create your card form:

* `CardNumberTextField` - Provides basic number grouping as the user types.
* `CardNameTextField` - Cardholder name field.
* `CardExpiryDateTextField` - Provides card expiration date input and styling
* `CardExpiryDatePicker` - `UIPickerView` implementation with a month and year column.
* `CardCVVTextField` - CVV number field.

Additionally, fields automatically turn red if their content fails
basic validation (e.g., alphabetic characters in the number field,
content with wrong length), and come in two supported styles: plain
and border.

#### Built-in Choose Payment Methods controller

The `presentChoosePaymentMethod` function of `OmiseSDK` presents a pre-made form that lets customers choose how they want to make a payment.
Please note that the presented controller is designed to be used as-is, and you should not push your view controllers into its navigation controller stack.
You can configure it to display either specified payment method options or a default list based on your country.

##### Use Choose Payment Methods controller

To use the controller in your application, call `presentChoosePaymentMethod`. 

```swift

omiseSDK.presentChoosePaymentMethod(
    from: self,
    amount: paymentAmount,
    currency: paymentCurrencyCode,
    delegate: self
)
```

You can provide extra parameters:
- `allowedPaymentMethods` to display given payment methods (if presented in Capability API)
- `forcePaymentMethods` to override payment methods from Capability and display only `allowedPaymentMethods`
- `isCardPaymentAllowed` to display or hide the Credit Card payment method
- `handleErrors` to process and display errors (by default, is `true`); if `false`, then the delegate 
method `choosePaymentMethodDidComplete(with error: Error)` will be called instead.

```swift

let allowedPaymentMethods = SourceType.availableByDefaultInThailand
omiseSDK.presentChoosePaymentMethod(
    from: self,
    amount: paymentAmount,
    currency: paymentCurrencyCode,
    allowedPaymentMethods: allowedPaymentMethods,
    forcePaymentMethods: true,
    isCardPaymentAllowed: true, 
    handleErrors: true,
    delegate: self
)

```

Then implement the delegate to receive the `Source` or `Token` object after the user has selected:

```swift
extension ProductDetailViewController: ChoosePaymentMethodDelegate {  
  func choosePaymentMethodDidComplete(with source: Source) {
    omiseSDK.dismiss {
      print(source.id) // prints Source ID
    }
  }
  
  func choosePaymentMethodDidComplete(with token: Token) {
    omiseSDK.dismiss {
      print(token.id) // prints Token ID
    }
  }

  func choosePaymentMethodDidComplete(with error: Error) {
    // Only called if we set `handleErrors = false`.

    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(okAction)

    let vc = omiseSDK.presentedViewController ?? self
    vc.present(alertController, animated: true, completion: nil)
  }
  
  func choosePaymentMethodDidCancel() {
      omiseSDK.dismiss()
  }
}
```

## Authorizing payment

Some payment methods require the customer to authorize the payment using an authorization URL. This includes [3-D Secure verification](https://docs.omise.co/fraud-protection#3-d-secure), [Internet Banking payment](https://docs.omise.co/internet-banking), [Mobile Banking SCB](https://docs.omise.co/mobile-banking-scb), etc. Omise iOS SDK provides a built-in class to handle the authorization.

On payment methods that require opening the external app (e.g., mobile banking app) to authorize the transaction, set the _return_uri_ to a **deep link** or **app link** to be able to open the merchant app. Otherwise, after the cardholder authorizes the transaction on the external app, the flow redirects to the normal link in the _return_uri_, and opens it on the browser app, resulting in the payment not being completed.
Some authorized URLs will be processed using the in-app browser flow, and others will be processed using the native flow from the SDK (3DS v2), and the SDK automatically handles all of this.

```swift

omiseSDK.presentAuthorizingPayment(
    from: self,
    authorizeURL: url,
    expectedReturnURLStrings: ["https://omise.co"],
    threeDSRequestorAppURLString: "merchantAppScheme://3ds_auth",
    threeDSUICustomization: nil
    delegate: self
)
```

Replace the string `authorizeURL` with the authorized URL that comes with the created charge and the array of string `expectedReturnURLStrings` with the expected pattern of redirected URLs array.
Replace the string `threeDSRequestorAppURLString` with the url of your app to allow the external bank apps to navigate back to your app when required.
Optional `threeDSUICustomization` parameter is used to customize the UI of the built-in 3DS SDK during the 3DS challenge flow.
If you want to customize the title of the authorizing payment activity, you must use the theme customization and pass the `headerText` in the `toolbarCustomization`

```swift
let toolbarUI = ThreeDSToolbarCustomization(
    backgroundColorHex: "#FFFFFF",
    headerText: "Secure Checkout",
    buttonText: "Close",
    textFontName: "Arial-BoldMT",
    textColorHex: "#000000",
    textFontSize: 20
)

let threeDSUICustomization = ThreeDSUICustomization(toolbarCustomization: toolbarUI)
```

You can check out the [ThreeDSUICustomization](./OmiseSDK/Sources/3DS/UICustomization/ThreeDSUICustomization.swift) class to see customizable UI elements in the challenge flow.

After the end-user completes the payment authorization process, the delegate callback will be triggered, and you will receive varying responses based on how the transaction was processed and the flow it used. Handle it as follows:

```swift
extension ViewController: AuthorizingPaymentDelegate {
    func authorizingPaymentDidComplete(with redirectedURL: URL?) {
        print("Payment is authorized with redirect url `\(String(describing: redirectedURL))`")
        omiseSDK.dismiss()
    }
    func authorizingPaymentDidCancel() {
        print("Payment is not authorized")
        omiseSDK.dismiss()
    }
}
```

You can check out the sample implementation in the [ProductDetailViewController](./ExampleApp/Views/ProductDetailViewController.swift#L68) class in the example app.

### Observing charge status in the token

The following utility function observes the token until its charge status changes. You can use it to check the charge status after the payment authorization process is completed.

```swift
func observeTokenChargeStatusHandler(tokenResult: Result<Token, Error>) -> Void {
    switch tokenResult {
    case .success(let token):
        // do something with Token id
        print(token.id)
    case .failure(let error):
        print(error)
    }
}

let client = omiseSDK.client
client.observeChargeStatus(observeTokenChargeStatusHandler)
```

### Authorizing payment via an external app

Some request methods allow the user to authorize the payment with an external app, for example Alipay. When a user needs to authorize the payment with an external app, `OmiseSDK` will automatically open an external app. However, merchant developers must handle the `AuthorizingPaymentDelegate` callback themselves.


### Passkey authentication

The SDK now supports PASSKEY alongside 3DS so users get the fastest available checkout flow. When you call your existing authorization code, the SDK inspects the authorize URL and picks the correct experience between 3DS vs PASSKEY automatically.

- Keep using `presentChoosePaymentMethod` or `presentCreditCardPayment` and provide the new `collect3DSData` option to decide whether you collect a phone number, email, or both (Default is none). For PASSKEY authentication to function properly, you must collect at least one of these fields (phone number or email).
- Continue to present `presentAuthorizingPayment` with the authorize URL from your `/charge` response; no other changes are required for merchants already supporting 3DS.
- PASSKEY relies on `SFSafariViewController`, so be sure your integration allows the SDK to present it when required.

```swift
omiseSDK.presentChoosePaymentMethod(
    from: self,
    amount: paymentAmount,
    currency: paymentCurrencyCode,
    allowedPaymentMethods: usesCapabilityDataForPaymentMethods ? nil : allowedPaymentMethods,
    isCardPaymentAllowed: true,
    handleErrors: true,
    collect3DSData: .all,
    delegate: self
)
```

If you need to present card form only, you can pass the same parameter to `presentCreditCardPayment` and supply the new `collect3DSData` like mentioned in the above. The SDK handles both PASSKEY and 3DS completion callbacks through `AuthorizingPaymentDelegate` exactly as described above.


## Objective-C compatibility

This version of Omise iOS SDK does not support Objective-C. For full Objective-C support, use [this version](https://github.com/omise/omise-ios/tree/support/v4.x.x).

## Contributing

Pull requests, issues, and bug fixes are welcome!

## License

MIT [See the full license text](https://github.com/omise/omise-ios/blob/master/LICENSE)
