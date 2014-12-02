//
//  CheckoutViewController.m
//  Omise-iOS_Test
//
//  Created on 2014/11/26.
//  Copyright (c) 2014 Omise Co.,Ltd. All rights reserved.
//

#import "CheckoutViewController.h"

@interface CheckoutViewController ()
@end

@implementation CheckoutViewController
@synthesize lblPrice;
@synthesize lblIslandNum;

static int islandNum;
static BOOL isClosing;

- (void)viewDidLoad {
    [super viewDidLoad];
    islandNum = 1;
    isClosing = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isClosing) {
        [self dismissViewControllerAnimated:YES completion:nil];
        isClosing = NO;
        return;
    }
    lblIslandNum.text = [NSString stringWithFormat:@"%d",islandNum];
    lblPrice.text = [NSString stringWithFormat:@"%dm USD", islandNum*2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onCancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+(void)setIslandNum:(int)_islandNum
{
    islandNum = _islandNum;
}
+(void)setIsClosing:(BOOL)_isClosing
{
    isClosing = _isClosing;
}


@end
