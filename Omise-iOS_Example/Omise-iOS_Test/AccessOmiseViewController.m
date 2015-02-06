//
//  AccessOmiseViewController.m
//  Omise-iOS_Test
//
//  Created on 2014/11/28.
//  Copyright (c) 2014 Omise Co.,Ltd. All rights reserved.
//

#import "AccessOmiseViewController.h"
#import "CheckoutViewController.h"
#import "SVProgressHUD.h"

@interface AccessOmiseViewController ()

@end

@implementation AccessOmiseViewController
@synthesize btnReset;
@synthesize btnToken;

bool succeeded;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestToOmise];
}

-(void)requestToOmise
{
    btnToken.titleLabel.text = @"Connecting...";
    
    TokenRequest* tokenRequest = [TokenRequest new];
    tokenRequest.publicKey = @"pkey_test_4y7dh41kuvvawbhslxw"; //required
    tokenRequest.card.name = @"JOHN DOE"; //required
    tokenRequest.card.city = @"Bangkok"; //required
    tokenRequest.card.postalCode = @"10320"; //required
    tokenRequest.card.number = @"4242424242424242"; //required
    tokenRequest.card.expirationMonth = @"11"; //required
    tokenRequest.card.expirationYear = @"2016"; //required
    
    Omise* omise = [Omise new];
    omise.delegate = self;
    [omise requestToken:tokenRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)onResetClick:(id)sender {
    [CheckoutViewController setIsClosing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onTokenClick:(id)sender {
    if (!succeeded) {
        [self requestToOmise];
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setValue:btnToken.titleLabel.text forPasteboardType:@"public.text"];
    
    [SVProgressHUD showSuccessWithStatus:@"copied to clipboard"];
}
- (IBAction)onCancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma OmiseTokenDelegate
-(void)omiseOnSucceededToken:(Token *)token
{
    [btnToken setTitle:token.tokenId forState:UIControlStateNormal];
    succeeded = YES;
}
-(void)omiseOnFailed:(NSError *)error
{
    [btnToken setTitle:@"Sorry, Please try again.." forState:UIControlStateNormal];
    [SVProgressHUD showErrorWithStatus:@"Sorry, Please try again.."];
    succeeded = NO;
}

@end
