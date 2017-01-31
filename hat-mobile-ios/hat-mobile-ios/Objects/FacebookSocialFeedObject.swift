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

class FacebookSocialFeedObject: SocialFeedObject {
    
    internal var tryingLastUpdate: Date?

    var name: String = ""
    var data: FacebookDataSocialFeedObject = FacebookDataSocialFeedObject()
    var id: Int = -1
    var lastUpdated: Date? = nil
    
    init() {
        
        name = ""
        data = FacebookDataSocialFeedObject()
        id = -1
        lastUpdated = nil
    }
    
        convenience init(from dict: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempName = dict["name"]?.stringValue {
            
            name = tempName
        }
        if let tempData = dict["data"]?.dictionaryValue {
            
            data = FacebookDataSocialFeedObject(from: tempData)
        }
        if let tempID = dict["id"]?.intValue {
            
            id = tempID
        }
        if let tempLastUpdated = dict["lastUpdated"]?.stringValue {
            
            lastUpdated = FormatterHelper.formatStringToDate(string: tempLastUpdated)
            tryingLastUpdate = lastUpdated
        }
    }
}
