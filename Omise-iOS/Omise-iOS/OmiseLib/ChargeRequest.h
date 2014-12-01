//
//  ChargeRequest.h
//  Omise-iOS
//
//  Created on 2014/12/01.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChargeRequest : NSObject

@property (nonatomic) NSString* secretKey;
@property (nonatomic) NSString* customer;
@property (nonatomic) NSString* card;
@property (nonatomic) NSString* returnUri;
@property (nonatomic) int amount;
@property (nonatomic) NSString* currency;
@property (nonatomic) BOOL capture;
@property (nonatomic) NSString* descriptionOfCharge;
@property (nonatomic) NSString* ip;


@end
