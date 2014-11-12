//
//  TokenRequest.h
//  Omise-iOS
//
//  Created on 2014/11/10.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface TokenRequest : NSObject

@property (nonatomic) Card* card;
@property (nonatomic) NSString* publicKey;

@end
