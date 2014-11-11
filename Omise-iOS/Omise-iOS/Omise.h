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

@protocol RequestTokenDelegate <NSObject>
-(void)onSucceeded:(Token*)token;
-(void)onFailed:(NSError*)error;
@end


@interface Omise : NSObject

@property (nonatomic) id<RequestTokenDelegate> delegate;

-(void)requestToken:(TokenRequest*)tokenRequest;

@end
