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

// MARK: Struct

/// A struct representing the data plug owner from data plug JSON file
struct DataPlugOwnerObject {
    
    // MARK: - Variables

    /// The id of the owner
    var id: String = ""
    /// The email of the owner
    var email: String = ""
    /// The nickname of the owner
    var nick: String = ""
    /// The first name of the owner
    var firstName: String = ""
    /// The last name of the owner
    var lastName: String = ""
    
    // MARK: - Initializers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        id = ""
        email = ""
        nick = ""
        firstName = ""
        lastName = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempID = (dict["id"]?.stringValue) {
            
            id = tempID
        }
        if let tempEmail = (dict["email"]?.stringValue) {
            
            email = tempEmail
        }
        if let tempNick = (dict["nick"]?.stringValue) {
            
            nick = tempNick
        }
        if let tempFirstName = (dict["firstName"]?.stringValue) {
            
            firstName = tempFirstName
        }
        if let tempLastName = (dict["lastName"]?.stringValue) {
            
            lastName = tempLastName
        }
    }
}
