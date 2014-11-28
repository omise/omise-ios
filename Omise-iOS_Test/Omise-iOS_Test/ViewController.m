//
//  ViewController.m
//  Omise-iOS_Test
//
//  Created on 2014/11/25.
//  Copyright (c) 2014 Omise Co.,Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CheckoutViewController.h"

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CheckoutViewController setIsClosing:NO];

    [self stepperValueChanged:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)stepperValueChanged:(id)sender {
    lblIsland.text = [NSString stringWithFormat:@"%d", (int)self.stIsland.value];
    lblPrice.text = [NSString stringWithFormat:@"$ %dm", (int)self.stIsland.value * 2];
    
    [CheckoutViewController setIslandNum:(int)self.stIsland.value];
}
@end
