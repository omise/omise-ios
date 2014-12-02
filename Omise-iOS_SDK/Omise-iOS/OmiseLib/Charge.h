//
//  Charge.h
//  Omise-iOS
//
//  Created on 2014/12/01.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Charge : NSObject

@property (nonatomic) NSString* chargeId;
@property (nonatomic) BOOL livemode;
@property (nonatomic) NSString* location;
@property (nonatomic) int amount;
@property (nonatomic) NSString* currency;
@property (nonatomic) NSString* descriptionOfCharge;
@property (nonatomic) BOOL capture;
@property (nonatomic) BOOL authorized;
@property (nonatomic) BOOL captured;
@property (nonatomic) NSString* transaction;
@property (nonatomic) NSString* returnUri;
@property (nonatomic) NSString* reference;
@property (nonatomic) NSString* authorizeUri;
@property (nonatomic) Card* card;
@property (nonatomic) NSString* customer;
@property (nonatomic) NSString* ip;
@property (nonatomic) NSString* created;

@end
