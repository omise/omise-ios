//
//  Charge.m
//  Omise-iOS
//
//  Created on 2014/12/01.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import "Charge.h"

@implementation Charge

@synthesize chargeId;
@synthesize livemode;
@synthesize location;
@synthesize amount;
@synthesize currency;
@synthesize descriptionOfCharge;
@synthesize capture;
@synthesize authorized;
@synthesize captured;
@synthesize transaction;
@synthesize returnUri;
@synthesize reference;
@synthesize authorizeUri;
@synthesize card;
@synthesize customer;
@synthesize ip;
@synthesize created;

-(id)init
{
    card = [Card new];
    return self;
}
@end
