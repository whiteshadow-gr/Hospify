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

public struct FileUploadObjectStatus {

    // MARK: - Variables
    
    public var status: String = ""
    public var size: Int?
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        status = ""
        size = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempStatus = dict["status"]?.stringValue {
            
            status = tempStatus
        }
        if let tempSize = dict["size"]?.intValue {
            
            size = tempSize
        }
    }
}
