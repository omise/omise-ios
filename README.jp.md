omise-ios
=========
tokenを生成するiOS(Cocoa)のライブラリです。
Omise-iosライブラリーは、Omise APIを用いたトークンの生成をするためのライブラリーです。 ライブラリーでトークンを生成する際に入力されるユーザカード情報は、あなたのサーバーを通る事はありません。 またこのライブラリーを用いる事で、ユーザーのカード情報を安全に保存し再度トークンをリクエストするだけでチャージすることができます。 この機能により、「1クリックチェックアウト」を実現する事ができます。 すべてのセンシティブパーソナルデータは私たちのPCI-DSS認証セキュアサーバーを通して行われ、安全かつ安心してご利用いただけるようにしております。



## Setup
{repo root}/Omise-iOS/Omise-iOS/OmiseLib にある全てのファイルをプロジェクトにコピーしてください。

## Primary classes
### Card
クレジットカードを表現します。

### TokenRequest
Tokenをリクエストする時に必要なパラメータを取りまとめるクラスです。このクラスのインスタンスに必要なパラメータをセットしてください。

### ChargeRequest
Chargeをリクエストする時に必要なパラメータを取りまとめるクラスです。このクラスのインスタンスに必要なパラメータをセットしてください。

### Token
tokenを表現します。リクエストに成功した時、delegateで渡されてくるのはこのクラスのインスタンスです。

### Charge
Chargeを表現します。リクエストに成功した時、delegateで渡されてくるのはこのクラスのインスタンスです。

### Omise
tokenをリクエストするクラスです。使い方は下記のサンプルコードをご覧ください。

### Test App
Omise-iOS_Test.xcodeproj を開き、ビルドするとTokenを作成するサンプルアプリが起動します。

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
    tokenRequest.publicKey = @"pkey_test_4ya6kkbjfporhk3gwnt"; //required
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
    
    
    //Charge example.
    ChargeRequest* chargeRequest = [ChargeRequest new];
    chargeRequest.secretKey = @"skey_test_4ya6kkbjg5oj9zx2caz";
    chargeRequest.amount = 1000;
    chargeRequest.currency = @"thb";
    chargeRequest.descriptionOfCharge = @"Order_1234";
    chargeRequest.returnUri = @"http://www.example.com/orders/9999/complete";
    chargeRequest.card = token.tokenId;
    
    Omise* omise = [Omise new];
    omise.delegate = self;
    [omise requestCharge:chargeRequest];
}

-(void)omiseOnSucceededCharge:(Charge *)charge
{
    //your code here
    //ex.
    NSString* created = charge.created;
}
```
