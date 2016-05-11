//
//  OmiseToken.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

import Foundation

public class OmiseToken: NSObject {
    
    var tokenId: String?
    var livemode: Bool?
    var location: String?
    var used: Bool?
    var card: OmiseCard?
    var created: String?
    
    override init() {
        card = OmiseCard()
    }
}
