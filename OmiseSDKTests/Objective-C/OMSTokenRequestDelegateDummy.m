#import "OMSTokenRequestDelegateDummy.h"

@implementation OMSTokenRequestDelegateDummy

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation {
    if (self = [super init]) {
        self.expectation = expectation;
    }
    return self;
}

- (void)tokenRequest:(OMSTokenRequest *)request didSucceedWithToken:(OMSToken *)token {
    self.request = request;
    self.token = token;
    self.error = nil;
    [self.expectation fulfill];
}

- (void)tokenRequest:(OMSTokenRequest *)request didFailWithError:(NSError *)error {
    self.request = request;
    self.error = error;
    self.token = nil;
    [self.expectation fulfill];
}

@end
