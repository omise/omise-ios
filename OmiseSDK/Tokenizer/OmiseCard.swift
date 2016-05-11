//
//  OmiseCard.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

public class OmiseCard {
    
    var cardId: String?
    var livemode: Bool?
    var location: String?
    var country: String?
    var financing: String?
    var lastDigits: String?
    var brand: String?
    var fingerprint: String?
    var securityCodeCheck: Bool?
    var created: String?
    
    // For create a token
    var name: String?
    var number: String?
    var expirationMonth: Int?
    var expirationYear: Int?
    var securityCode: String?
    var city: String?           // Optional
    var postalCode: String?     // Optional
}
