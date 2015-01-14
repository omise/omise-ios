//
//  Omise.m
//
//  Created on 2014/11/10.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import "Omise.h"
@implementation Omise{
    NSMutableData* data;
    TokenRequest* mTokenRequest;
    ChargeRequest* mChargeRequest;
    CustomerRequest* mCustomerRequest;
    BOOL isConnecting;
    
    int requestingApi;
}

enum OmiseApi{
    OmiseToken = 1,
    OmiseCharge,
    OmiseCreateCustomer,
};



@synthesize delegate;

-(instancetype)init
{
    isConnecting = NO;
    return self;
}

-(void)requestToken:(TokenRequest *)tokenRequest
{
    if (isConnecting) {
        NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                        code:OmiseServerConnectionError
                                                    userInfo:@{@"Connection error": @"Running other request."}];
        [delegate omiseOnFailed:omiseError];
        return;
    }
    isConnecting = YES;
    requestingApi = OmiseToken;

    
    data = [NSMutableData new];
    mTokenRequest = tokenRequest;
    
    NSURL* url = [NSURL URLWithString:@"https://vault.omise.co/tokens"];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
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

-(void)requestCharge:(ChargeRequest *)chargeRequest
{
    if (isConnecting) {
        NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                        code:OmiseServerConnectionError
                                                    userInfo:@{@"Connection error": @"Running other request."}];
        [delegate omiseOnFailed:omiseError];
        return;
    }
    isConnecting = YES;
    requestingApi = OmiseCharge;
    
    
    
    data = [NSMutableData new];
    mChargeRequest = chargeRequest;
    
    NSURL* url = [NSURL URLWithString:@"https://api.omise.co/charges"];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    [req setHTTPMethod:@"POST"];
    
    NSMutableString* body = [NSMutableString new];
    [body appendFormat:@"card=%@&return_uri=%@&amount=%d&capture=%@&description=%@",mChargeRequest.card,mChargeRequest.returnUri,mChargeRequest.amount,(mChargeRequest.capture ? @"true" : @"false"),mChargeRequest.descriptionOfCharge];

    if (mChargeRequest.customer && [mChargeRequest.customer length] > 0) {
        [body appendFormat:@"&customer=%@",mChargeRequest.customer];
    }
    if (mChargeRequest.ip && [mChargeRequest.customer length] > 0) {
        [body appendFormat:@"&ip=%@",mChargeRequest.ip];
    }
    if (mChargeRequest.currency && [mChargeRequest.currency length] > 0) {
        [body appendFormat:@"&currency=%@",mChargeRequest.currency];

    }
    
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *loginString = [NSString stringWithFormat:@"%@:%@", mChargeRequest.secretKey, @""];
    NSData *plainData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *base64LoginData = [NSString stringWithFormat:@"Basic %@",base64String];
    [req setValue:base64LoginData forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    [connection start];
}

-(void)requestCreateCustomer:(CustomerRequest*)customerRequest
{
    
    
    if (isConnecting) {
        NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                        code:OmiseServerConnectionError
                                                    userInfo:@{@"Connection error": @"Running other request."}];
        [delegate omiseOnFailed:omiseError];
        return;
    }
    isConnecting = YES;
    requestingApi = OmiseCreateCustomer;
    
    
    
    data = [NSMutableData new];
    mCustomerRequest = customerRequest;
    
    NSURL* url = [NSURL URLWithString:@"https://api.omise.co/customers"];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    [req setHTTPMethod:@"POST"];
    
    NSMutableString* body = [NSMutableString new];
    
    if (mCustomerRequest.email && [mCustomerRequest.email length] > 0) {
        [body appendFormat:@"&email=%@",mCustomerRequest.email];
    }
    if (mCustomerRequest.descriptionOfCustomer && [mCustomerRequest.descriptionOfCustomer length] > 0) {
        [body appendFormat:@"&description=%@",mCustomerRequest.descriptionOfCustomer];
    }
    if (mCustomerRequest.card && [mCustomerRequest.card length] > 0) {
        [body appendFormat:@"&card=%@",mCustomerRequest.card];
        
    }
    
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *loginString = [NSString stringWithFormat:@"%@:%@", mCustomerRequest.secretKey, @""];
    NSData *plainData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *base64LoginData = [NSString stringWithFormat:@"Basic %@",base64String];
    [req setValue:base64LoginData forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    [connection start];
}




#pragma NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [data appendData:d];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSError* omiseError = nil;
    if (error.code == NSURLErrorTimedOut) {
        omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                        code:OmiseTimeoutError
                                                    userInfo:@{@"Request timeout": @"Request timeout"}];
    }else{
        omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                        code:OmiseServerConnectionError
                                                    userInfo:@{@"Can not connect Omise server": @"Check your parameter and internet connection."}];
    }
    isConnecting = NO;
    [delegate omiseOnFailed:omiseError];
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge.previousFailureCount > 0) {
        [challenge.sender cancelAuthenticationChallenge:challenge];
        NSError *error = [NSError errorWithDomain:@"error on didReceiveAuthenticationChallenge" code:INT32_MIN userInfo:NULL];
        [self connection:connection didFailWithError:error];
        
        
        NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                        code:OmiseServerConnectionError
                                                    userInfo:@{@"Connection error": @"Authentication failed."}];
        [delegate omiseOnFailed:omiseError];
        return;
    }
    
    if (requestingApi == OmiseToken) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:mTokenRequest.publicKey
                                                                 password:@""
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }else if(requestingApi == OmiseCharge){
        NSURLCredential *credential = [NSURLCredential credentialWithUser:mChargeRequest.secretKey
                                                                 password:@""
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }else if(requestingApi == OmiseCreateCustomer){
        NSURLCredential *credential = [NSURLCredential credentialWithUser:mCustomerRequest.secretKey
                                                                 password:@""
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
}
-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    JsonParser *jsonParser = [JsonParser new];
    
    Token* token;
    Charge* charge;
    Customer* customer;
    
    switch (requestingApi) {
        case OmiseCharge:
            charge = [jsonParser parseOmiseCharge:responseText];
            if (charge) {
                [delegate omiseOnSucceededCharge:charge];
            }else{
                NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                                code:OmiseBadRequestError
                                                            userInfo:@{@"Invalid param": @"Invalid public key or parameters."}];
                [delegate omiseOnFailed:omiseError];
            }
            break;
            
        case OmiseToken:
            token = [jsonParser parseOmiseToken:responseText];
            if (token) {
                [delegate omiseOnSucceededToken:token];
            }else{
                NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                                code:OmiseBadRequestError
                                                            userInfo:@{@"Invalid param": @"Invalid public key or parameters."}];
                [delegate omiseOnFailed:omiseError];
            }
            break;
            
        case OmiseCreateCustomer:
            customer = [jsonParser parseOmiseCreateCustomer:responseText];
            if (customer) {
                [delegate omiseOnSucceededCreateCustomer:customer];
            }else{
                NSError* omiseError = [[NSError alloc]initWithDomain:OmiseErrorDomain
                                                                code:OmiseBadRequestError
                                                            userInfo:@{@"Invalid param": @"Invalid public key or parameters."}];
                [delegate omiseOnFailed:omiseError];
            }
            break;
            
        default:
            break;
    }
    isConnecting = NO;
}

@end
