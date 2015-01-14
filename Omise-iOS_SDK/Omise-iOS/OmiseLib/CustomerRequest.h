//
//  CustomerRequest.h
//  Omise-iOS
//
//  Created on 2015/01/14.
//  Copyright (c) 2015年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerRequest : NSObject

@property (nonatomic) NSString* secretKey;
@property (nonatomic) NSString* descriptionOfCustomer;
@property (nonatomic) NSString* email;
@property (nonatomic) NSString* card;

@end
