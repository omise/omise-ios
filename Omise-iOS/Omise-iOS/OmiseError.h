//
//  OmiseError.h
//  Omise-iOS
//
//  Created by AD-PC92MAC on 2014/11/12.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OmiseError : NSError
FOUNDATION_EXPORT NSString *const OmiseErrorDomain;

enum OmiseErrorCode{
    OmiseTimeoutError = 92661,
    OmiseServerConnectionError,
    OmiseBadRequestError,
    OmiseUnknownError,
};
@end
