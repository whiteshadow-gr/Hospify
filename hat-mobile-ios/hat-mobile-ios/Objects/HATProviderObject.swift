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

// MARK: Struct

/// A class representing the hat provider object
struct HATProviderObject {
    
    // MARK: - Variables

    /// The hat provider's sku number
    var sku: String = ""
    /// The hat provider's name
    var name: String = ""
    /// The hat provider's description
    var description: String = ""
    /// The hat provider's details
    var details: String = ""
    /// The hat provider's illustration url
    var illustration: String = ""
    
    /// The hat provider's price
    var price: Int = 0
    /// The hat provider's available hats
    var available: Int = 0
    /// The hat provider's purchased hats
    var purchased: Int = 0
    /// The hat provider's ordering
    var ordering: Int = 0
    
    /// The hat provider's hat features
    var features: [String] = []
    
    /// The hat provider's image
    var hatProviderImage: UIImage? = nil
    
    /// The hat provider's category object
    var category: HATProviderCategoryObject = HATProviderCategoryObject()
    /// The hat provider's kind object
    var kind: HATProviderKindObject = HATProviderKindObject()
    /// The hat provider's payment type
    var paymentType: HATProviderPaymentObject = HATProviderPaymentObject()
    
    // MARK: Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
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
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
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
