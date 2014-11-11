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
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:mTokenRequest.card.name forKey:@"card[name]"];
    [req setValue:mTokenRequest.card.city forKey:@"card[city]"];
    [req setValue:mTokenRequest.card.postalCode forKey:@"card[postal_code]"];
    [req setValue:mTokenRequest.card.number forKey:@"card[number]"];
    [req setValue:mTokenRequest.card.expirationMonth forKey:@"card[expiration_month]"];
    [req setValue:mTokenRequest.card.expirationYear forKey:@"card[expiration_year]"];
    
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
    [delegate onFailed:error];
}



// Handle basic authentication challenge if needed
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSString *username = mTokenRequest.publicKey;
    NSString *password = @"";
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username
                                                             password:password
                                                          persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(responseText);
}

@end
