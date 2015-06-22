omise-ios
=========

`omise-ios` is a Cocoa library for managing token with Omise API.

By using the token produced by this library, you will be able to securely process payment transaction without letting sensitive information pass through your server.
This token can also be used to create customer card data which will allow re-using of card data for the next payment without entering it again.

All data are transmitted via HTTPS to our PCI-DSS certified server.


## Installation

Please copy all files in `{repo root}/Omise-iOS/Omise-iOS/OmiseLib` into your project.

### 1. Flow

The following flow is recommended in order to comply with the PCI Security Standards.
You should never transmit card data through your servers unless you have a valid PCI certificate.

Flow using `Omise-iOS`

1. User enters the credit card information on iOS app.
2. The card is sent directly from the the app to Omise server via HTTPS using this `omise-ios` SDK.
3. Omise returns a Token that identifies the card and if the card passed the authorization `card.security_code_check`

Your page will send this token to your server to finally make the charge capture.

#### Notes:
In step 3, if `card.security_code_check` is `false`, the card failed the authorization process, probably because of a wrong CVV, wrong expire date or wrong card number.
In this case you should display an error message and ask user to enter card again.

In step 4, Omise will make the final capture of the amount. If this fail, but token was authorized, it can be due to card having no funds required for the charge.

### 2. The Code

#### Request a token

ExampleViewController.h
```objc
#import "ExampleViewController.h"
@implementation ExampleViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    //set parameters
    TokenRequest* tokenRequest = [TokenRequest new];
    tokenRequest.publicKey = @"pkey_test_4ya6kkbjfporhk3gwnt"; //required
    tokenRequest.card.name = @"JOHN DOE"; //required
    tokenRequest.card.city = @"Bangkok"; //required
    tokenRequest.card.postalCode = @"10320"; //required
    tokenRequest.card.number = @"4242424242424242"; //required
    tokenRequest.card.expirationMonth = @"11"; //required
    tokenRequest.card.expirationYear = @"2016"; //required
    tokenRequest.card.securityCode = @"123"; //required

    //request
    Omise* omise = [Omise new];
    omise.delegate = self;
    [omise requestToken:tokenRequest];
}


#pragma OmiseRequestDelegate
-(void)omiseOnFailed:(NSError *)error
{
    //handle error
    //see OmiseError.h and .m
}

-(void)omiseOnSucceededToken:(Token *)token
{
    //your code here
    //ex.
    NSString* brand = token.card.brand;
    NSString* location = token.location;
    BOOL livemode = token.livemode;
}

```

## Primary classes

### Card

A class representing a card information.

### TokenRequest

A class encapsulating parameters for requesting token. You will have to set card information as a parameter for this class.

### Token

A class representing token. This class is what will be passed to the delegate if the request is successful.

### Omise

A class for requesting token. See also sample code below.

### Test app

By opening Omise-iOS_Test.xcodeproj and building it on Xcode, the sample application will launch and create a charge token to test.
