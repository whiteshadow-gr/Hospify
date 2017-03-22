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

/// A class representing the hat provider category object
struct ProviderCategoryObject {
    
    /// MARK: - Variables

    /// The hat provider's category id
    var categoryId: Int = 0
    
    /// The hat provider's category title
    var title: String = ""
    /// The hat provider's category description
    var description: String = ""
    /// The hat provider's category illustration url
    var illustration: String = ""
    
    /// MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        categoryId = 0
        
        title = ""
        description = ""
        illustration = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempCategoryId = dictionary["categoryId"]?.intValue {
            
            categoryId = tempCategoryId
        }
        
        if let tempTitle = dictionary["title"]?.stringValue {
            
            title = tempTitle
        }
        if let tempDescription = dictionary["description"]?.stringValue {
            
            description = tempDescription
        }
        if let tempIllustration = dictionary["illustration"]?.stringValue {
            
            illustration = tempIllustration
        }
    }
}
