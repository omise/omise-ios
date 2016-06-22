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
`CreditCardPopoverController` as popover from your application. This view controller
provides a pre-made credit card form and will automatically [tokenize credit card
 information](https://www.omise.co/security-best-practices) for you. You only need to
implement the delegate.

You can use the controller in popover mode using the `presentViewController` method:

```swift
import OmiseSDK

@IBAction func displayCreditCardForm() {
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
