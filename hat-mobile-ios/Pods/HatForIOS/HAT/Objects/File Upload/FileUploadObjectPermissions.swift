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

public class FileUploadObjectPermissions: NSObject {
    
    // MARK: - Variables
    
    public var userID: String = ""
    public var contentReadable: String = ""

    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public override init() {
        
        userID = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public convenience init(from dict: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempUserID = dict["userID"]?.stringValue {
            
            userID = tempUserID
        }
        if let tempContentReadable = dict["contentReadable"]?.stringValue {
            
            contentReadable = tempContentReadable
        }
    }
}
