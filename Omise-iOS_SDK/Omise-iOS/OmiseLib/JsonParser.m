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
    
//    NSLog(json);
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

-(Charge *)parseOmiseCharge:(NSString *)json
{
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
//    NSLog(json);
    if(jsonObject){
        
        NSString* obj = [jsonObject objectForKey:@"object"];
        if ([obj isEqualToString:@"error"]) {
            return nil;
        }
        
        Charge* charge = [Charge new];
        charge.chargeId = [jsonObject objectForKey:@"id"];
        charge.livemode = [(NSNumber *)[jsonObject objectForKey:@"livemode"]boolValue];
        charge.location = [jsonObject objectForKey:@"location"];
        charge.amount = [[jsonObject objectForKey:@"amount"]intValue];
        charge.currency = [jsonObject objectForKey:@"currency"];
        charge.descriptionOfCharge = [jsonObject objectForKey:@"description"];
        charge.capture = [(NSNumber *)[jsonObject objectForKey:@"capture"]boolValue];
        charge.authorized = [(NSNumber *)[jsonObject objectForKey:@"authorized"]boolValue];
        charge.captured = [(NSNumber *)[jsonObject objectForKey:@"captured"]boolValue];
        charge.transaction = [jsonObject objectForKey:@"transaction"];
        charge.returnUri = [jsonObject objectForKey:@"return_uri"];
        charge.reference = [jsonObject objectForKey:@"reference"];
        charge.authorizeUri = [jsonObject objectForKey:@"authorize_uri"];
        
        NSDictionary* cardObject = [jsonObject objectForKey:@"card"];
        charge.card.cardId= [cardObject objectForKey:@"id"];
        charge.card.livemode = [(NSNumber *)[cardObject objectForKey:@"livemode"]boolValue];
        charge.card.country = [cardObject objectForKey:@"country"];
        charge.card.city = [cardObject objectForKey:@"city"];
        charge.card.postalCode = [cardObject objectForKey:@"postal_code"];
        charge.card.financing = [cardObject objectForKey:@"financing"];
        charge.card.lastDigits = [cardObject objectForKey:@"last_digits"];
        charge.card.brand = [cardObject objectForKey:@"brand"];
        charge.card.expirationMonth = [cardObject objectForKey:@"expiration_month"];
        charge.card.expirationYear = [cardObject objectForKey:@"expiration_year"];
        charge.card.fingerprint = [cardObject objectForKey:@"fingerprint"];
        charge.card.name = [cardObject objectForKey:@"name"];
        charge.card.created = [cardObject objectForKey:@"created"];
        
        
        charge.customer = [jsonObject objectForKey:@"customer"];
        charge.created = [jsonObject objectForKey:@"created"];
        charge.ip = [jsonObject objectForKey:@"ip"];
        
        return charge;
    }
    return nil;
}

/*
 {
 "object": "charge",
 "id": "chrg_test_4xso2s8ivdej29pqnhz",
 "livemode": false,
 "location": "/charges/chrg_test_4xso2s8ivdej29pqnhz",
 "amount": 100000,
 "currency": "thb",
 "description": "Order-384",
 "capture": true,
 "authorized": false,
 "captured": false,
 "transaction": null,
 "return_uri": "https://example.co.th/orders/384/complete",
 "reference": "9qt1b3n635uv6plypp2spzkpe",
 "authorize_uri": "https://api.omise-gateway.dev/payments/9qt1b3n635uv6plypp2spzkpe/authorize",
 "card": {
 "object": "card",
 "id": "card_test_4xs94086bpvq56tghuo",
 "livemode": false,
 "country": "th",
 "city": "Bangkok",
 "postal_code": "10320",
 "financing": "credit",
 "last_digits": "4242",
 "brand": "Visa",
 "expiration_month": 10,
 "expiration_year": 2018,
 "fingerprint": "/LCaOoTah/+As+qKsohIldZkEfew0Zq2nJKgIObRwMI=",
 "name": "Somchai Prasert",
 "created": "2014-10-20T09:41:56Z"
 },
 "customer": null,
 "ip": "127.0.0.1",
 "created": "2014-10-21T11:12:28Z"
 }
 */
@end
