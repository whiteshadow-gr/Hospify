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

/// A class representing the locations received from server
class HATLocationsObject: NSObject {
    
    // MARK: - Variables
    
    /// The id of the location record
    var id: Int = 0
    /// The last updated date of the record
    var lastUpdate: Date? = nil
    /// The name of the record
    var name: String = ""
    /// The data of the location object
    var data: HATLocationsDataObject = HATLocationsDataObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    override init() {
        
        id = 0
        lastUpdate = nil
        name = ""
        data = HATLocationsDataObject()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(dict: Dictionary<String, JSON>) {
        
        // init optional JSON fields to default values
        self.init()
        
        // this field will always have a value no need to use if let
        if let tempID = dict["id"]?.intValue {
            
            id = tempID
        }
        
        if let tempUpdatedTime = dict["lastUpdated"]?.string {
            
            lastUpdate = HATFormatterHelper.formatStringToDate(string: tempUpdatedTime)
        }
        
        if let tempName = dict["name"]?.string {
            
            name = tempName
        }
        
        if let tempTables = dict["data"]?.dictionaryValue {
            
            data = HATLocationsDataObject(dict: tempTables)
        }
    }
}
