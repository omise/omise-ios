//
//  OmiseRequestObject.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

import Foundation

public class OmiseRequestObject: NSObject {
    
    public var publicKey: String?
    public var card: OmiseCard?
    
    public override init() {
        card = OmiseCard()
    }
}