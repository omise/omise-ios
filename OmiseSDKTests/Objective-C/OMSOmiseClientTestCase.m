#import <XCTest/XCTest.h>
@import OmiseSDK;
#import "OMSSDKTestCase.h"
#import "OMSTokenRequestDelegateDummy.h"


NSString * const _Nonnull  publicKey = @"pkey_test_58wfnlwoxz1tbkdd993";


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface OMSOmiseClientTestCase : OMSSDKTestCase

@property (nonatomic, nullable, strong) OMSSDKClient *testClient;

@end


@implementation OMSOmiseClientTestCase

- (void)setUp {
    self.testClient = [[OMSSDKClient alloc] initWithPublicKey:publicKey];
}

- (void)tearDown {
    self.testClient = nil;
}

- (void)testRequestWithDelegate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async delegate callback"];
    OMSTokenRequestDelegateDummy *delegate = [[OMSTokenRequestDelegateDummy alloc] initWithExpectation:expectation];
    
    [self.testClient sendRequest:[OMSOmiseClientTestCase createValidTestRequest] delegate:delegate];
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(delegate.token);
        XCTAssertNotNil(delegate.request);
        XCTAssertNil(delegate.error);
        
        XCTAssertTrue([@"4242" isEqualToString:delegate.token.card.lastDigits]);
        XCTAssertEqual(11, delegate.token.card.expirationMonth);
        XCTAssertEqual(2019, delegate.token.card.expirationYear);
    }];
}

- (void)testBadRequestWithDelegate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async delegate callback"];
    OMSTokenRequestDelegateDummy *delegate = [[OMSTokenRequestDelegateDummy alloc] initWithExpectation:expectation];

    [self.testClient sendRequest:[OMSOmiseClientTestCase createInvalidTestRequest] delegate:delegate];
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(delegate.error);
        XCTAssertNotNil(delegate.request);
        XCTAssertNil(delegate.token);
    }];
}

- (void)testRequestWithCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
    
    [self.testClient sendRequest:[OMSOmiseClientTestCase createValidTestRequest] callback:^(OMSToken * _Nullable token, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(token);
        
        XCTAssertTrue([@"4242" isEqualToString:token.card.lastDigits]);
        XCTAssertEqual(11, token.card.expirationMonth);
        XCTAssertEqual(2019, token.card.expirationYear);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void)testBadRequestWithCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
    
    [self.testClient sendRequest:[OMSOmiseClientTestCase createInvalidTestRequest] callback:^(OMSToken * _Nullable token, NSError * _Nullable error) {
        XCTAssertNil(token);
        XCTAssertNotNil(error);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}


+ (OMSTokenRequest *)createInvalidTestRequest {
    return [[OMSTokenRequest alloc] initWithName:@"JOHN DOE" number:@"42424242424242421111" expirationMonth:11 expirationYear:2019 securityCode:@"123" city:nil postalCode:nil];
}

+ (OMSTokenRequest *)createValidTestRequest {
    return [[OMSTokenRequest alloc] initWithName:@"JOHN DOE" number:@"4242424242424242" expirationMonth:11 expirationYear:2019 securityCode:@"123" city:nil postalCode:nil];
}

@end

#pragma clang diagnostic pop


