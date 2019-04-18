#import <Foundation/Foundation.h>
@import OmiseSDK;
@import XCTest;


@interface OMSTokenRequestDelegateDummy : NSObject <OMSTokenRequestDelegate>

@property (nonatomic, nullable, strong) OMSTokenRequest *request;
@property (nonatomic, nullable, strong) OMSToken *token;
@property (nonatomic, nullable, strong) NSError *error;

@property (nonatomic, nonnull, strong) XCTestExpectation *expectation;

- (instancetype _Nonnull)initWithExpectation:(XCTestExpectation * _Nonnull)expectation;

@end


@interface OMSSourceRequestDelegateDummy : NSObject <OMSSourceRequestDelegate>

@property (nonatomic, nullable, strong) OMSSourceRequest *request;
@property (nonatomic, nullable, strong) OMSSource *source;
@property (nonatomic, nullable, strong) NSError *error;

@property (nonatomic, nonnull, strong) XCTestExpectation *expectation;

- (instancetype _Nonnull)initWithExpectation:(XCTestExpectation * _Nonnull)expectation;

@end


