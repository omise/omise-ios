omise-ios
=========

omise-ios is a Cocoa library for managing credit cards and payment authorization with the Omise API.

By using the tokens produced by this library, you will be able to securely process credit cards without letting sensitive information pass through your server. These tokens can also be used to store references to card details which allow customers to reuse cards for their future payments without entering their information again.

All data are transmitted via HTTPS to our PCI-DSS certified server.

## Setup

Omise-iOS-Swift is available through [CocoaPods]. To install it, simply add the following line to your `Podfile`:

    pod 'omise-ios', '~> 1.0'

Alternatively, to install manually, please copy all files in `{repository root}/Omise-iOS/Omise-iOS/OmiseLib` into your project.

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

## Request a token

`ExampleViewController.h`:

```objc
#import <UIKit/UIKit.h>
#import "Omise.h"
#import "TokenRequest.h"
#import "Card.h"

@interface ExampleViewController : UIViewController <OmiseRequestTokenDelegate>
@end
```

`ExampleViewController.m`:

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

[CocoaPods]: http://cocoapods.org/
