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

class FacebookDataPostsApplicationSocialFeedObject {

    var id: String = ""
    var namespace: String = ""
    var name: String = ""
    var category: String = ""
    var link: String = ""
    
    init() {
        
        id = ""
        namespace = ""
        name = ""
        category = ""
        link = ""
    }
    
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
        if let tempNameSpace = dictionary["namespace"]?.stringValue {
            
            namespace = tempNameSpace
        }
        if let tempName = dictionary["name"]?.string {
            
            name = tempName
        }
        if let tempCategory = dictionary["category"]?.stringValue {
            
            category = tempCategory
        }
        if let tempLink = dictionary["link"]?.stringValue {
            
            link = tempLink
        }
    }
}
