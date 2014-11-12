//
//  Token.m
//  Omise-iOS
//
//  Created on 2014/11/10.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import "Token.h"

@implementation Token

@synthesize tokenId;
@synthesize livemode;
@synthesize location;
@synthesize used;
@synthesize card;
@synthesize created;

-(id)init
{
    card = [Card new];
    return self;
}
@end
