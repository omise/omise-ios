//
//  OmiseRequestObject.swift
//  OmiseSDK
//
//  Created by Anak Mirasing on 5/11/16.
//  Copyright © 2016 Omise. All rights reserved.
//

import Foundation

public class OmiseRequestObject: NSObject {
    
    var publicKey: String?
    var card: OmiseCard?
    
    override init() {
        card = OmiseCard()
    }
}