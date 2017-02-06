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

/// A class representing the twitter social feed object
class TwitterSocialFeedObject: SocialFeedObject {
    
    // MARK: - Protocol's variables
    
    internal var protocolLastUpdate: Date? = nil
    
    // MARK: - Class' variables
    
    /// The name of the record in database
    var name: String = ""
    /// The id of the record
    var id: String = ""
    
    /// The actual data of the record
    var data: TwitterDataSocialFeedObject = TwitterDataSocialFeedObject()
    
    /// The last updated field of the record
    var lastUpdated: Date? = nil
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        name = ""
        data = TwitterDataSocialFeedObject()
        id = ""
        lastUpdated = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempName = dictionary["name"]?.stringValue {
            
            name = tempName
        }
        if let tempData = dictionary["data"]?.dictionaryValue {
            
            data = TwitterDataSocialFeedObject(from: tempData)
        }
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
        if let tempLastUpdated = dictionary["lastUpdated"]?.stringValue {
            
            lastUpdated = FormatterHelper.formatStringToDate(string: tempLastUpdated)
            protocolLastUpdate = lastUpdated
        }
    }
}
