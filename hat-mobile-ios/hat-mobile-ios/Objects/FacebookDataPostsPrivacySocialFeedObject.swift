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

/// A class representing the privacy settings of the post
class FacebookDataPostsPrivacySocialFeedObject {
    
    // MARK: - Variables

    /// Is it friends only?
    var friends: String = ""
    /// The value
    var value: String = ""
    /// deny access?
    var deny: String = ""
    /// The desctiption of the setting
    var description: String = ""
    /// Allow?
    var allow: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        friends = ""
        value = ""
        deny = ""
        description = ""
        allow = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempFriends = dictionary["friends"]?.stringValue {
            
            friends = tempFriends
        }
        if let tempValue = dictionary["value"]?.stringValue {
            
            value = tempValue
        }
        if let tempDeny = dictionary["deny"]?.string {
            
            deny = tempDeny
        }
        if let tempDescription = dictionary["description"]?.stringValue {
            
            description = tempDescription
        }
        if let tempAllow = dictionary["allow"]?.stringValue {
            
            allow = tempAllow
        }
    }
}
