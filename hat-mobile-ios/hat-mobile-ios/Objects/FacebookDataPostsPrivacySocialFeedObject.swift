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

class FacebookDataPostsPrivacySocialFeedObject {

    var friends: String = ""
    var value: String = ""
    var deny: String = ""
    var description: String = ""
    var allow: String = ""
    
    init() {
        
        friends = ""
        value = ""
        deny = ""
        description = ""
        allow = ""
    }
    
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
