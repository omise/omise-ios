//
//  Omise_iOS.h
//  Omise
//
//  Created on 2014/11/10.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Token.h"
#import "TokenRequest.h"
#import "JsonParser.h"

@protocol OmiseRequestTokenDelegate <NSObject>
-(void)omiseOnSucceeded:(Token*)token;
-(void)omiseOnFailed:(NSError*)error;
@end


@interface Omise : NSObject <NSURLConnectionDelegate>

@property (nonatomic) id<OmiseRequestTokenDelegate> delegate;

-(void)requestToken:(TokenRequest*)tokenRequest;

@end
