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
    ChargeRequest* chargeRequest = [ChargeRequest new];
    
    /*
    tokenRequest.publicKey = tfPublicKey.text;
    tokenRequest.card.name = @"JOHN DOE";
    tokenRequest.card.city = @"Bangkok";
    tokenRequest.card.postalCode = @"10320";
    tokenRequest.card.number = @"4242424242424242";
    tokenRequest.card.expirationMonth = @"11";
    tokenRequest.card.expirationYear = @"2016";
    [omise requestToken:tokenRequest];
     */

    
    chargeRequest.secretKey = @"skey_test_4y8nekxw2icd4xo8fi1";
    chargeRequest.customer = @"cust_test_4y8nip97pty0w917lr0";
    chargeRequest.amount = 10000;
    chargeRequest.currency = @"thb";
    chargeRequest.descriptionOfCharge = @"Order-384";
    chargeRequest.card = @"card_test_4y8nla3can535zbhzjh";
    [omise requestCharge:chargeRequest];
    
    //tokn_test_4y8nkbui94dp3ohd9da
    //card_test_4y8nkbugwxctngn2r8v
    //pkey_test_4y8nekxw3pr6lgvp3nv
    //skey_test_4y8nekxw2icd4xo8fi1
    //cust_test_4y8nip97pty0w917lr0
}


#pragma OmiseRequestTokenDelegate
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
}

-(void)omiseOnSucceededCharge:(Charge *)charge
{
    
}




#pragma tfPublicKey delegate
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    return YES;
}

@end
