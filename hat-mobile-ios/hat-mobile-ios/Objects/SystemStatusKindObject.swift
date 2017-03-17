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

/// A class representing the system status kind object
class SystemStatusKindObject: NSObject {
    
    // MARK: - Variables

    /// The value of the object
    var metric: String = ""
    /// The kind of the value of the object
    var kind: String = ""
    /// The unit type of the value of the object
    var units: String? = nil
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    override init() {
        
        metric = ""
        kind = ""
        units = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempMetric = dictionary["metric"]?.stringValue {
            
            metric = tempMetric
        }
        if let tempKind = dictionary["kind"]?.stringValue {
            
            kind = tempKind
        }
        if let tempUnits = dictionary["units"]?.stringValue {
            
            units = tempUnits
        }
    }
}
