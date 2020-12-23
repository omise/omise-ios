# 3D Secure 2

The previous version of 3D Secure (3DS) redirected the cardholder to the bank's website,
3D Secure 2 (3DS2) now provides strong customer authentication allowing the customer to authenticate directly within the merchant application.

## Get Started
To use 3DS2, merchant can download directly from [OmiseThreeDSSDK](https://github.com/omise/omise-ios/blob/3ds-v2/OmiseThreeDSSDK/OmiseThreeDSSDK.xcframework.zip)

## Installation
1. Extract `OmiseThreeDSSDK.xcframework.zip`
2. Embedding `OmiseThreeDSSDK.xcframework` by Drag and drop `OmiseThreeDSSDK.xcframework` into your project
3. On `Choosing options for adding these files` dialog, select `Copy items if needed`
4. On `General -> Targets -> Frameworks, Libraries, and Embeded content`, select `Embed & Sign`
5. Done

## Usage
You can create an instance of `ThreeDSService` and set it with `authorized URL` given with the Omise Charge and `expected return URL` patterns those were created by merchants in the case. 

If your authorization cannot use 3DS2, the OmiseThreeDSSDK will throw authorization back to the `throwbackToAuthorizingPaymentVersionOne` delegation method.
```swift 
// ViewController

let authorizeURL = URL(string: "http://localhost:8080/payments/123456789/authorize_url")
let expectedReturnURLPatterns = [URLComponents(string: "http://localhost:8080/charge/order/123456789")!]
let threeDSService = ThreeDSService()
threeDSService.doAuthorizingPaymentWithAuthorizeURL(authorizeURL, 
                                                    expectedReturnURLPatterns: expectedReturnURLPatterns, 
                                                    challengeStatusReceiver: self)
```

#### Receive `3DS2 Authorizing Payment` events via the delegate for handle result of Authorization
Implement the delegate to receive the Authorization status after cardholder has entered the authorization data:
```swift 
// ViewController
extension ViewController: ThreeDSChallengeStatusReceiver {
  func completed(_ completionEvent: ThreeDSCompletionEvent) {
    // Called when the challenge process (that is, the transaction) is completed.
  }
  
  func cancelled() {
    // Called when the Cardholder selects the option to cancel the transaction on the challenge screen.
  }
  
  func timedout() {
    // Called when the challenge process reaches or exceeds the timeout interval.
  }
  
  func protocolError(_ protocolErrorEvent: ThreeDSProtocolErrorEvent) {
    // Called when the 3DS SDK receives an EMV 3-D Secure protocol-defined error message from the ACS(Access Control Server).
  }
  
  func runtimeError(_ runtimeErrorEvent: ThreeDSRuntimeErrorEvent) {
    // Called when the 3DS SDK encounters errors during the challenge process. 
  }
  
  func throwbackToAuthorizingPaymentVersionOne(_ authorizeURL: URL, _ expectedReturnURLPatterns: [URLComponents]) {
    // Use AuthorizingPaymentViewController from Omise iOS SDK to handle 3DS1
    let handlerController = AuthorizingPaymentViewController.makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(authorizeURL, expectedReturnURLPatterns: expectedReturnURLPatterns, delegate: self)
    self.present(handlerController, animated: true, completion: nil)
  }
}
```

## Configurations
These are the available configurations in 3DS2.

| Config | Description |
|---|---|
| `uiCustomization` | Configuration for UI customization in the challenge flow. |
| `timeout` | Maximum timeout for the challenge flow. The acceptable timeout is 5-99 mins. |

#### Authorization UI Customization
You can create your own theme for Authorization UI.
OmiseThreeDSSDK provides custom UI components to make it easier to custom your theme.
* `UICustomization`
  * `NavigationBarCustomization`
  * `LabelCustomization`
  * `TextFieldCustomization`
  * `ButtonCustomization`
  
Then you can put UICustomize instance when initial `ThreeDSService`
```swift
let uiCustomization = UICustomization(toolbarCustomization: NavigationBarCustomization?,
                                      labelCustomization: LabelCustomization?,
                                      textBoxCustomization: TextFieldCustomization?,
                                      buttonCustomizations: [ButtonType: ButtonCustomization]) 
let threeDSService = ThreeDSService(uiCustomization: uiCustomization)
```

#### Authorization Timeout
Timeout interval (in minutes) within which the challenge process must be completed. The minimum timeout interval shall be 5 minutes in default.
```swift
// Use default timeout 5 minutes
let threeDSService = ThreeDSService()

// Use custom timeout. Ex. 2 minutes
let threeDSService = ThreeDSService(uiCustomization: nil, timeout: 2)
```

## How to check status of Omise Charge via Omise Token ID
We also prepare methods for checking `Charge` status by `OmiseTokenID` that merchant use to create a `Charge`
```swift
import OmiseSDK

let omiseSDKClient = Client(publicKey: "omise_public_key")
// One time use
omiseSDKClient.retrieveChargeStatusWithCompletionHandler(from: "omise_token_id", completionHandler: { [weak self]result in
      switch result {
      case .success(let chargeStatus):
        // Handle ChargeStatus
      case .failure(let error):
        // Handle error
      }
    })

// Or use this method for polling (pull Charge status every 3 second until exceed the limit(10 times) or Charge status changed to Success or Failed)
omiseSDKClient.pollingChargeStatusWithCompletionHandler(from: omiseToken.id) { [weak self](result) in
      switch result {
      case .success(let chargeStatus):
        // Handle ChargeStatus
      case .failure(let error):
        // Handle error
      }
    }
```
