//
//  ViewController.m
//  Omise-iOS
//
//  Created on 2014/11/11.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize tfPublicKey;
@synthesize tvJson;

- (void)viewDidLoad {
    [super viewDidLoad];
    tfPublicKey.delegate = self;
    [self test:1];
//    [self test:2];
}

- (IBAction)onConnectClick:(id)sender {
//    [self test:1];
}


-(void)test:(int)api
{
    tvJson.text = @"connecting...";
    
    Omise* omise = [Omise new];
    omise.delegate = self;
    
    TokenRequest* tokenRequest = [TokenRequest new];
    tokenRequest.publicKey = tfPublicKey.text;
    tokenRequest.publicKey = @"pkey_test_4ya6kkbjfporhk3gwnt";
    tokenRequest.card.name = @"JOHN DOE";
    tokenRequest.card.city = @"Bangkok";
    tokenRequest.card.postalCode = @"10320";
    tokenRequest.card.number = @"4242424242424242";
    tokenRequest.card.expirationMonth = @"11";
    tokenRequest.card.expirationYear = @"2016";
    [omise requestToken:tokenRequest];
    
}


#pragma OmiseRequestDelegate
-(void)omiseOnFailed:(NSError *)error
{
    tvJson.text = [NSString stringWithFormat:@"Failed.. %@",error.description];
}

-(void)omiseOnSucceededToken:(Token *)token
{
    tvJson.text = [NSString stringWithFormat:@"token:{\n\ttokenId:%@\n\tlivemode:%d\n\tlocation:%@\n\tused:%d\n\tcard:{\n\t\tcardId:%@\n\t\tlivemode:%d\n\t\tcountry:%@\n\t\tcity:%@\n\t\tpostal_code:%@\n\t\tfinancing:%@\n\t\tlast_digits:%@\n\t\tbrand:%@\n\t\texpiration_month:%@\n\t\texpiration_year:%@\n\t\tfingerprint:%@\n\t\tname:%@\n\t\tcreated:%@\n\t}\n\tcreated:%@\n}",
                   token.tokenId,
                   token.livemode,
                   token.location,
                   token.used,
                   token.card.cardId,
                   token.card.livemode,
                   token.card.country,
                   token.card.city,
                   token.card.postalCode,
                   token.card.financing,
                   token.card.lastDigits,
                   token.card.brand,
                   token.card.expirationMonth,
                   token.card.expirationYear,
                   token.card.fingerprint,
                   token.card.name,
                   token.card.created,
                   token.created
                   ];
    
    Omise* omise = [Omise new];
    omise.delegate = self;
}

#pragma tfPublicKey delegate
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    return YES;
}

@end
