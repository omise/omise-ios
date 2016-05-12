//
//  OmiseToken.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

import Foundation

public class OmiseToken: NSObject {
    
    public var tokenId: String?
    public var livemode: Bool?
    public var location: String?
    public var used: Bool?
    public var card: OmiseCard?
    public var created: String?
    
    override init() {
        card = OmiseCard()
    }
}
