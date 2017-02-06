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

// MARK: Class

/// A class representing the application that this post came from
class FacebookDataPostsApplicationSocialFeedObject {
    
    // MARK: - Variables

    /// The id of the application
    var id: String = ""
    /// The namespace of the application
    var namespace: String = ""
    /// The name of the application
    var name: String = ""
    /// The category of the application
    var category: String = ""
    /// The link of the application
    var link: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        id = ""
        namespace = ""
        name = ""
        category = ""
        link = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
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
