//
//  Omise.m
//
//  Created on 2014/11/10.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import "Omise.h"

@implementation Omise{
    NSMutableData* data;
    TokenRequest* mTokenRequest;
}
@synthesize delegate;



-(void)requestToken:(TokenRequest *)tokenRequest
{
    data = [NSMutableData new];
    mTokenRequest = tokenRequest;
    
    NSURL* url = [NSURL URLWithString:@"https://vault.omise.co/tokens"];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [req setHTTPMethod:@"POST"];
    
    NSString* body = [NSString stringWithFormat:@"card[name]=%@&card[city]=%@&card[postal_code]=%@&card[number]=%@&card[expiration_month]=%@&card[expiration_year]=%@",
                      mTokenRequest.card.name,
                      mTokenRequest.card.city,
                      mTokenRequest.card.postalCode,
                      mTokenRequest.card.number,
                      mTokenRequest.card.expirationMonth,
                      mTokenRequest.card.expirationYear];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *loginString = [NSString stringWithFormat:@"%@:%@", mTokenRequest.publicKey, @""];
    NSData *plainData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *base64LoginData = [NSString stringWithFormat:@"Basic %@",base64String];
    

    [req setValue:base64LoginData forHTTPHeaderField:@"Authorization"];
    

    
    
    
    
    
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    [connection start];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate omiseOnFailed:error];
}



-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge.previousFailureCount > 0) {
        // 失敗していたらエラーとする。
        [challenge.sender cancelAuthenticationChallenge:challenge];
        NSError *error = [NSError errorWithDomain:@"error on authentication challenge" code:INT32_MIN userInfo:NULL];
        [self connection:connection didFailWithError:error];
        NSLog(@"fail");
        return;
    }
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:mTokenRequest.publicKey
                                                             password:@""
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //return YES to say that we have the necessary credentials to access the requested resource
    return YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(responseText);
    
}

@end
