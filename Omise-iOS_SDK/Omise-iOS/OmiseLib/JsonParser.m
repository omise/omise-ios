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

-(Customer*)parseOmiseCreateCustomer:(NSString*)json
{
    
    
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    
    
    
    if(jsonObject){
        
        NSString* obj = [jsonObject objectForKey:@"object"];
        if ([obj isEqualToString:@"error"]) {
            return nil;
        }
        
        Customer* customer = [Customer new];
        customer._id = [jsonObject objectForKey:@"id"];
        customer.livemode = [(NSNumber *)[jsonObject objectForKey:@"livemode"]boolValue];
        customer.location = [jsonObject objectForKey:@"location"];
        customer.defaultCard = [jsonObject objectForKey:@"default_card"];
        customer.email = [jsonObject objectForKey:@"email"];
        customer.descriptionOfCustomer = [jsonObject objectForKey:@"description"];
        customer.created = [jsonObject objectForKey:@"created"];

        NSDictionary* cardsObject = [jsonObject objectForKey:@"cards"];
        Cards* cards = [Cards new];
        cards.from = [cardsObject objectForKey:@"from"];
        cards.to = [cardsObject objectForKey:@"to"];
        cards.offset = [[cardsObject objectForKey:@"offset"]intValue];;
        cards.limit = [[cardsObject objectForKey:@"limit"]intValue];;
        cards.total = [[cardsObject objectForKey:@"total"]intValue];;
        cards.location = [cardsObject objectForKey:@"location"];
        
        
        NSMutableArray* cardArray = [NSMutableArray new];
        NSArray* cardsData = [cardsObject objectForKey:@"data"];
        for (int i=0; i<(int)cardsData.count; i++) {
            NSDictionary* cardObject = [cardsData objectAtIndex:i];
            Card* card = [Card new];
            card.cardId= [cardObject objectForKey:@"id"];
            card.livemode = [(NSNumber *)[cardObject objectForKey:@"livemode"]boolValue];
            card.country = [cardObject objectForKey:@"country"];
            card.city = [cardObject objectForKey:@"city"];
            card.postalCode = [cardObject objectForKey:@"postal_code"];
            card.financing = [cardObject objectForKey:@"financing"];
            card.lastDigits = [cardObject objectForKey:@"last_digits"];
            card.brand = [cardObject objectForKey:@"brand"];
            card.expirationMonth = [cardObject objectForKey:@"expiration_month"];
            card.expirationYear = [cardObject objectForKey:@"expiration_year"];
            card.fingerprint = [cardObject objectForKey:@"fingerprint"];
            card.name = [cardObject objectForKey:@"name"];
            card.created = [cardObject objectForKey:@"created"];
            card.securityCodeCheck = [(NSNumber *)[cardObject objectForKey:@"security_code_check"]boolValue];
            [cardArray addObject:card];
        }
        
        cards.cards = cardArray;
        customer.cards = cards;
        
        return customer;
    }
    return nil;
}

@end
