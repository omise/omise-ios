//
//  Cards.h
//  Omise-iOS
//
//  Created on 2015/01/14.
//  Copyright (c) 2015年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cards : NSObject

@property (nonatomic) NSString* from;
@property (nonatomic) NSString* to;
@property (nonatomic) int offset;
@property (nonatomic) int limit;
@property (nonatomic) int total;
@property (nonatomic) NSMutableArray* cards;
@property (nonatomic) NSString* location;

@end
