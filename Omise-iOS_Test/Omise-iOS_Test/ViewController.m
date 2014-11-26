//
//  ViewController.m
//  Omise-iOS_Test
//
//  Created by AD-PC92MAC on 2014/11/25.
//  Copyright (c) 2014年 Alpha-Do.Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize btnCheckout;
@synthesize checkoutBase;
@synthesize lblIsland;
@synthesize lblPrice;
@synthesize stIsland;

- (void)viewDidLoad {
    [super viewDidLoad];
    checkoutBase.layer.cornerRadius = 5;
    checkoutBase.alpha = 0.75;
    btnCheckout.layer.cornerRadius = 5;
    btnCheckout.alpha = 0.9;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)stepperValueChanged:(id)sender {
    lblIsland.text = [NSString stringWithFormat:@"%d", (int)self.stIsland.value];
    lblPrice.text = [NSString stringWithFormat:@"$ %dm", (int)self.stIsland.value * 2];
    
}

@end
