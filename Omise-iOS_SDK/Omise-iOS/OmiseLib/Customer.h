//
//  Customer.h
//  Omise-iOS
//
//  Created on 2015/01/14.
//  Copyright (c) 2015年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cards.h"

@interface Customer : NSObject

@property (nonatomic) NSString* _id;
@property (nonatomic) bool livemode;
@property (nonatomic) NSString* location;
@property (nonatomic) NSString* defaultCard;
@property (nonatomic) NSString* email;
@property (nonatomic) NSString* descriptionOfCustomer;
@property (nonatomic) NSString* created;
@property (nonatomic) Cards* cards;

@end
