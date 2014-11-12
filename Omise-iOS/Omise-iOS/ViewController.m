//
//  ViewController.m
//  Omise-iOS
//
//  Created on 2014/11/11.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "TokenRequest.h"
#import "Card.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TokenRequest* tokenRequest = [TokenRequest new];
    tokenRequest.publicKey = @"pkey_test_4y144m01arclxagi4gc";
    tokenRequest.card.name = @"JOHN DOE";
    tokenRequest.card.city = @"Bangkok";
    tokenRequest.card.postalCode = @"10320";
    tokenRequest.card.number = @"4242424242424242";
    tokenRequest.card.expirationMonth = @"11";
    tokenRequest.card.expirationYear = @"2016";
    
    Omise* omise = [Omise new];
    omise.delegate = self;
    [omise requestToken:tokenRequest];
}

#pragma OmiseRequestTokenDelegate
-(void)omiseOnFailed:(NSError *)error
{
    
}

-(void)omiseOnSucceeded:(Token *)token
{
    
}

@end
