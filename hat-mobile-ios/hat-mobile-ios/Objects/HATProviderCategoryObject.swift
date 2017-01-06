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

struct HATProviderCategoryObject {

    var categoryId: Int = 0
    
    var title: String = ""
    var description: String = ""
    var illustration: String = ""
    
    init() {
        
        categoryId = 0
        
        title = ""
        description = ""
        illustration = ""
    }
    
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
