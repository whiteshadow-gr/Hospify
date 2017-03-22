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

/// A class representing the locations actual data
class HATLocationsDataLocationsObject: NSObject {
    
    // MARK: - Variables

    /// The latitude of the location
    var latitude: String = ""
    /// The longitude of the location
    var longitude: String = ""
    /// The accuracy of the location
    var accuracy: String = ""
    /// The date of the location
    var timeStamp: Date? = nil
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    override init() {
        
        latitude = ""
        longitude = ""
        accuracy = ""
        timeStamp = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        // this field will always have a value no need to use if let
        if let tempLatitude = dict["latitude"]?.stringValue {
            
            latitude = tempLatitude
        }
        
        if let tempLongitude = dict["longitude"]?.stringValue {
            
            longitude = tempLongitude
        }
        
        if let tempAccuracy = dict["accuracy"]?.stringValue {
            
            accuracy = tempAccuracy
        }
        
        if let tempTimeStamp = dict["timestamp"]?.stringValue {
            
            timeStamp = HATFormatterHelper.formatStringToDate(string: tempTimeStamp)
        }
    }
}
