#import <XCTest/XCTest.h>
@import OmiseSDK;
#import "OMSRequestDelegateDummy.h"


NSString * const _Nonnull publicKey = @"pkey_test_58wfnlwoxz1tbkdd993";


@interface OMSOmiseClientTestCase : XCTestCase

@property (nonatomic, nullable, strong) OMSSDKClient *testClient;

@end


@implementation OMSOmiseClientTestCase

- (void)setUp {
    self.testClient = [[OMSSDKClient alloc] initWithPublicKey:publicKey];
}

- (void)tearDown {
    self.testClient = nil;
}

#pragma mark - Token Requests test

- (void)testTokenRequestWithDelegate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async delegate callback"];
    OMSTokenRequestDelegateDummy *delegate = [[OMSTokenRequestDelegateDummy alloc] initWithExpectation:expectation];
    
    [self.testClient sendTokenRequest:[OMSOmiseClientTestCase createValidTestTokenRequest] delegate:delegate];
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(delegate.token);
        XCTAssertNotNil(delegate.request);
        XCTAssertNil(delegate.error);
        
        XCTAssertTrue([@"4242" isEqualToString:delegate.token.card.lastDigits]);
        XCTAssertEqual(11, delegate.token.card.expirationMonth);
        XCTAssertEqual(2020, delegate.token.card.expirationYear);
    }];
}

- (void)testBadTokenRequestWithDelegate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async delegate callback"];
    OMSTokenRequestDelegateDummy *delegate = [[OMSTokenRequestDelegateDummy alloc] initWithExpectation:expectation];

    [self.testClient sendTokenRequest:[OMSOmiseClientTestCase createInvalidTestTokenRequest] delegate:delegate];
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(delegate.error);
        XCTAssertNotNil(delegate.request);
        XCTAssertNil(delegate.token);
    }];
}

- (void)testTokenRequestWithCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
    
    [self.testClient sendTokenRequest:[OMSOmiseClientTestCase createValidTestTokenRequest] callback:^(OMSToken * _Nullable source, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(source);
        
        XCTAssertTrue([@"4242" isEqualToString:source.card.lastDigits]);
        XCTAssertEqual(11, source.card.expirationMonth);
        XCTAssertEqual(2020, source.card.expirationYear);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void)testBadTokenRequestWithCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
    
    [self.testClient sendTokenRequest:[OMSOmiseClientTestCase createInvalidTestTokenRequest] callback:^(OMSToken * _Nullable source, NSError * _Nullable error) {
        XCTAssertNil(source);
        XCTAssertNotNil(error);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}


#pragma mark - Source Requests test

- (void)testSourceRequestWithDelegate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async delegate callback"];
    OMSSourceRequestDelegateDummy *delegate = [[OMSSourceRequestDelegateDummy alloc] initWithExpectation:expectation];
    
    [self.testClient sendSourceRequest:[OMSOmiseClientTestCase createValidTestSourceRequest] delegate:delegate];
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(delegate.source);
        XCTAssertNotNil(delegate.request);
        XCTAssertNil(delegate.error);
        
        XCTAssertTrue([@"THB" isEqualToString:delegate.source.currencyCode]);
        XCTAssertEqual(10000, delegate.source.amount);
    }];
}

- (void)testBadSourceRequestWithDelegate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async delegate callback"];
    OMSSourceRequestDelegateDummy *delegate = [[OMSSourceRequestDelegateDummy alloc] initWithExpectation:expectation];
    
    [self.testClient sendSourceRequest:[OMSOmiseClientTestCase createInvalidTestSourceRequest] delegate:delegate];
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(delegate.error);
        XCTAssertNotNil(delegate.request);
        XCTAssertNil(delegate.source);
        
        XCTAssertTrue([delegate.error.localizedDescription containsString:@"not supported"]);
        XCTAssertTrue([delegate.error.localizedDescription containsString:@"source"]);
        XCTAssertTrue([delegate.error.localizedDescription containsString:@"type"]);
    }];
}

- (void)testSourceRequestWithCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
    
    [self.testClient sendSourceRequest:[OMSOmiseClientTestCase createValidTestSourceRequest] callback:^(OMSSource * _Nullable source, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(source);
        
        XCTAssertTrue([@"THB" isEqualToString:source.currencyCode]);
        XCTAssertEqual(10000, source.amount);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void)testBadSourceRequestWithCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
    
    [self.testClient sendSourceRequest:[OMSOmiseClientTestCase createInvalidTestSourceRequest] callback:^(OMSSource * _Nullable source, NSError * _Nullable error) {
        XCTAssertNil(source);
        XCTAssertNotNil(error);
        
        XCTAssertTrue([error.localizedDescription containsString:@"not supported"]);
        XCTAssertTrue([error.localizedDescription containsString:@"source"]);
        XCTAssertTrue([error.localizedDescription containsString:@"type"]);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}



#pragma mark - Request builder

+ (OMSTokenRequest *)createInvalidTestTokenRequest {
    return [[OMSTokenRequest alloc] initWithName:@"JOHN DOE" number:@"42424242424242421111"
                                 expirationMonth:6
                                  expirationYear:[[NSCalendar creditCardInformationCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]] + 1
                                    securityCode:@"123" city:nil postalCode:nil];
}

+ (OMSTokenRequest *)createValidTestTokenRequest {
    return [[OMSTokenRequest alloc] initWithName:@"JOHN DOE" number:@"4242424242424242"
                                 expirationMonth:11
                                  expirationYear:[[NSCalendar creditCardInformationCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]] + 1
                                    securityCode:@"123" city:nil postalCode:nil];
}

+ (OMSSourceRequest *)createInvalidTestSourceRequest {
    OMSPaymentInformation *customPaymentInformation = [[OMSCustomPaymentInformation alloc] initWithCustomType:@"INVALID SOURCE" parameters:@{}];
    return [[OMSSourceRequest alloc] initWithPaymentInformation:customPaymentInformation amount:0 currencyCode:@"INVALID_CURRENCY"];
}

+ (OMSSourceRequest *)createValidTestSourceRequest {
    return [[OMSSourceRequest alloc] initWithPaymentInformation:OMSInternetBankingPaymentInformation.bayInternetBankingPayment
                                                         amount:10000 currencyCode:OMSSupportedCurrencyCodeTHB];
}

@end

