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

struct DataOfferIssuerObject {
    
    // MARK: - Variables

    var id: String = ""
    var email: String = ""
    var nick: String = ""
    var firstName: String = ""
    var lastName: String = ""
    
    // MARK: - Initialisers
    
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
    init(dictionary: Dictionary<String, JSON>) {
        
        if let tempID = dictionary["id"]?.string {
            
            id = tempID
        }
        
        if let tempEmail = dictionary["email"]?.string {
            
            email = tempEmail
        }
        
        if let tempNick = dictionary["nick"]?.string {
            
            nick = tempNick
        }
        
        if let tempFirstName = dictionary["firstName"]?.string {
            
            firstName = tempFirstName
        }
        
        if let tempLastName = dictionary["lastName"]?.string {
            
            lastName = tempLastName
        }
    }
}
