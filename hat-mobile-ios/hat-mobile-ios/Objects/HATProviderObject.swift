/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit
import SwiftyJSON

struct HATProviderObject {

    var sku: String = ""
    var name: String = ""
    var description: String = ""
    var details: String = ""
    var illustration: String = ""
    
    var price: Int = 0
    var available: Int = 0
    var purchased: Int = 0
    var ordering: Int = 0
    
    var features: [String] = []
    
    var hatProviderImage: UIImage? = nil
    
    var category: HATProviderCategoryObject = HATProviderCategoryObject()
    var kind: HATProviderKindObject = HATProviderKindObject()
    var paymentType: HATProviderPaymentObject = HATProviderPaymentObject()
    
    init() {
        
        sku = ""
        name = ""
        description = ""
        details = ""
        illustration = ""
        
        price = 0
        available = 0
        purchased = 0
        ordering = 0
        
        features = []
        
        hatProviderImage = nil
        
        category = HATProviderCategoryObject()
        kind = HATProviderKindObject()
        paymentType = HATProviderPaymentObject()
    }
    
    init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempSKU = dictionary["sku"]?.stringValue {
            
            sku = tempSKU
        }
        if let tempName = dictionary["name"]?.stringValue {
            
            name = tempName
        }
        if let tempDescription = dictionary["description"]?.stringValue {
            
            description = tempDescription
        }
        if let tempDetails = dictionary["details"]?.stringValue {
            
            details = tempDetails
        }
        if let tempIllustration = dictionary["illustration"]?.stringValue {
            
            illustration = tempIllustration
        }
        
        if let tempPrice = dictionary["price"]?.intValue {
            
            price = tempPrice
        }
        if let tempAvailable = dictionary["available"]?.intValue {
            
            available = tempAvailable
        }
        if let tempPurchased = dictionary["purchased"]?.intValue {
            
            purchased = tempPurchased
        }
        if let tempOrdering = dictionary["ordering"]?.intValue {
            
            ordering = tempOrdering
        }
        
        if let tempFeatures = dictionary["features"]?.arrayValue {
            
            for item in tempFeatures {
                
               features.append(item.stringValue)
            }
        }
        
        if let tempKind = dictionary["kind"]?.dictionaryValue {
            
            kind = HATProviderKindObject(from: tempKind)
        }
        if let tempPaymentType = dictionary["paymentType"]?.dictionaryValue {
            
            paymentType = HATProviderPaymentObject(from: tempPaymentType)
        }
        if let tempCategory = dictionary["category"]?.dictionaryValue {
            
            category = HATProviderCategoryObject(from: tempCategory)
        }
    }
}
