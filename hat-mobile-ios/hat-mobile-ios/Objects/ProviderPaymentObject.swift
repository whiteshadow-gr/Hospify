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

import SwiftyJSON

// MARK: Struct

/// A class representing the hat provider payment object
struct ProviderPaymentObject {
    
    // MARK: - Variables

    /// The subscription type, Monthly , yearly
    var subscription: Dictionary = ["period" : ""]
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        subscription = ["period" : ""]
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempSubscription = dictionary["Subscription"]?.dictionaryValue {
            
            if let value = tempSubscription["period"]?.stringValue {
                
                subscription = ["period" : value]
            }
        }
    }
}
