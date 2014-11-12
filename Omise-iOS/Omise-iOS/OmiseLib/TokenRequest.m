//
//  TokenRequest.m
//  Omise-iOS
//
//  Created on 2014/11/10.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import "TokenRequest.h"

@implementation TokenRequest

@synthesize card;
@synthesize publicKey;

-(id)init
{
    card = [Card new];
    return self;
}

@end
