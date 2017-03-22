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

/// A class representing the data of the locations object
class HATLocationsDataObject: NSObject {

    /// The locations
    var locations: HATLocationsDataLocationsObject = HATLocationsDataLocationsObject()
        
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    override init() {
    
        locations = HATLocationsDataLocationsObject()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(dict: Dictionary<String, JSON>) {
        
        // init optional JSON fields to default values
        self.init()
        
        if let tempFields = dict["locations"]?.dictionaryValue {
            
            locations = HATLocationsDataLocationsObject(dict: tempFields)
        }
    }
}
