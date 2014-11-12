omise-ios
=========
tokenを生成するiOS(Cocoa)のライブラリです。

## Setup
{repo root}/Omise-iOS/Omise-iOS/OmiseLib にある全てのファイルをプロジェクトにコピーしてください。

## Primary classes
### Card
クレジットカードを表現します。

### TokenRequest
tokenをリクエストする時に必要なパラメータを取りまとめるクラスです。このクラスのインスタンスに必要なパラメータをセットしてください。

### Token
tokenを表現します。リクエストに成功した時、delegateで渡されてくるのはこのクラスのインスタンスです。

### Omise
tokenをリクエストするクラスです。使い方は下記のサンプルコードをご覧ください。

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
    //ex.
    NSString* brand = token.card.brand;
    NSString* location = token.location;
    BOOL livemode = token.livemode;
}
```
