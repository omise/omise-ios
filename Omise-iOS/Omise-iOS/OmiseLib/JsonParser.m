//
//  JsonParser.m
//  Omise-iOS
//
//  Created on 2014/11/12.
//  Copyright (c) 2014年 Omise Co., Ltd. All rights reserved.
//

#import "JsonParser.h"

@implementation JsonParser


-(Token*)parseOmiseToken:(NSString *)json
{
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];

    if(jsonObject){
        
        NSString* obj = [jsonObject objectForKey:@"object"];
        if ([obj isEqualToString:@"error"]) {
            return nil;
        }
        
        Token* token = [Token new];
        
        token.tokenId = [jsonObject objectForKey:@"id"];
        token.livemode = [(NSNumber *)[jsonObject objectForKey:@"livemode"]boolValue];
        token.location = [jsonObject objectForKey:@"location"];
        token.used = [(NSNumber *)[jsonObject objectForKey:@"used"]boolValue];
        token.created = [jsonObject objectForKey:@"created"];
        
        NSDictionary* cardObject = [jsonObject objectForKey:@"card"];
        token.card.cardId= [cardObject objectForKey:@"id"];
        token.card.livemode = [(NSNumber *)[cardObject objectForKey:@"livemode"]boolValue];
        token.card.country = [cardObject objectForKey:@"country"];
        token.card.city = [cardObject objectForKey:@"city"];
        token.card.postalCode = [cardObject objectForKey:@"postal_code"];
        token.card.financing = [cardObject objectForKey:@"financing"];
        token.card.lastDigits = [cardObject objectForKey:@"last_digits"];
        token.card.brand = [cardObject objectForKey:@"brand"];
        token.card.expirationMonth = [cardObject objectForKey:@"expiration_month"];
        token.card.expirationYear = [cardObject objectForKey:@"expiration_year"];
        token.card.fingerprint = [cardObject objectForKey:@"fingerprint"];
        token.card.name = [cardObject objectForKey:@"name"];
        token.card.created = [cardObject objectForKey:@"created"];
     
        return token;
    }
    
    return nil;
}

@end
