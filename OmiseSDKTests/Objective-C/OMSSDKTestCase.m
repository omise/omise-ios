#import "OMSSDKTestCase.h"

@implementation OMSSDKTestCase

+ (NSData *)fixturesDataForFileName:(NSString *)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[OMSSDKTestCase class]];
    NSURL *url = [bundle URLForResource:[@"Fixtures/objects/" stringByAppendingString:filename] withExtension:@"json"];
    return [[NSData alloc] initWithContentsOfURL:url];
}

@end
