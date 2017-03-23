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
public class HATLocationsObject: Equatable {
    
    // MARK: - Equatable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: HATLocationsObject, rhs: HATLocationsObject) -> Bool {
        
        return (lhs.id == rhs.id && lhs.lastUpdate == rhs.lastUpdate && lhs.name == rhs.name && lhs.data == rhs.data)
    }
    
    // MARK: - Variables
    
    /// The id of the location record
    public var id: Int = 0
    /// The last updated date of the record
    public var lastUpdate: Date? = nil
    /// The name of the record
    public var name: String = ""
    /// The data of the location object
    public var data: HATLocationsDataObject = HATLocationsDataObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
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
