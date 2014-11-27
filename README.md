omise-ios
=========

omise-ios is a Cocoa library for managing token with Omise API.

By using the token produced by this library, you will be able to securely process credit card without letting sensitive information pass through your server. This token can also be used to create customer card data which will allow re-using of card data for the next payment without entering it again.

All data are transmitted via HTTPS to our PCI-DSS certified server.

## Setup

Please copy all files in {repo root}/Omise-iOS/Omise-iOS/OmiseLib into your project.

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

ExampleViewController.h
```objc
#import <UIKit/UIKit.h>
#import "Omise.h"
#import "TokenRequest.h"
#import "Card.h"

@interface ExampleViewController : UIViewController <OmiseRequestTokenDelegate>
@end
```
    
ExampleViewController.m
```objc
#import "ExampleViewController.h"
@implementation ExampleViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //set parameters
    TokenRequest* tokenRequest = [TokenRequest new];
    tokenRequest.publicKey = @"pkey_test_xxxxxxxxxxxxxxxxxxx"; //required
    tokenRequest.card.name = @"JOHN DOE"; //required
    tokenRequest.card.city = @"Bangkok"; //required
    tokenRequest.card.postalCode = @"10320"; //required
    tokenRequest.card.number = @"4242424242424242"; //required
    tokenRequest.card.expirationMonth = @"11"; //required
    tokenRequest.card.expirationYear = @"2016"; //required
    
    //request
    Omise* omise = [Omise new];
    omise.delegate = self;
    [omise requestToken:tokenRequest];
}


#pragma OmiseRequestTokenDelegate
-(void)omiseOnFailed:(NSError *)error
{
    //handle error
    //see OmiseError.h and .m
}

-(void)omiseOnSucceeded:(Token *)token
{
    //your code here
