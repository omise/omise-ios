//
//  Card.h
//  Omise-iOS
//
//  Created on 2014/11/10.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (nonatomic) NSString* cardId;
@property (nonatomic) BOOL livemode;
@property (nonatomic) NSString* location;
@property (nonatomic) NSString* country;
@property (nonatomic) NSString* number;
@property (nonatomic) NSString* city;
@property (nonatomic) NSString* postalCode;
@property (nonatomic) NSString* financing;
@property (nonatomic) NSString* lastDigits;
@property (nonatomic) NSString* brand;
@property (nonatomic) NSString* expirationMonth;
@property (nonatomic) NSString* expirationYear;
@property (nonatomic) NSString* fingerprint;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* created;


@end
