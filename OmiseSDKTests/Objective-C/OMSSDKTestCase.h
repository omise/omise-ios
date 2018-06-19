#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface OMSSDKTestCase : XCTestCase

+ (NSData * _Nullable )fixturesDataForFileName:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
