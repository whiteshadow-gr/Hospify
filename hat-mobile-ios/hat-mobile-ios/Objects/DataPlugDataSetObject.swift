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

struct DataPlugDataSetObject {

    var name: String = ""
    var description: String = ""
    var fields: [DataPlugDataSetObject] = []
    
    init() {
        
        name = ""
        description = ""
        fields = []
    }
    
    init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempName = (dict["name"]?.stringValue) {
            
            name = tempName
        }
        if let tempDescription = (dict["description"]?.stringValue) {
            
            description = tempDescription
        }
        if let tempFields = (dict["fields"]?.dictionaryValue) {
            
            fields = [DataPlugDataSetObject(dict: tempFields)]
        }
    }
}
