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

struct DataPlugOwnerObject {

    var id: String = ""
    var email: String = ""
    var nick: String = ""
    var firstName: String = ""
    var lastName: String = ""
    
    init() {
        
        id = ""
        email = ""
        nick = ""
        firstName = ""
        lastName = ""
    }
    
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
