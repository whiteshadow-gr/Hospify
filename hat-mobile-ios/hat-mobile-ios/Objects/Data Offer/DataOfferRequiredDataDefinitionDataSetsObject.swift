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

struct DataOfferRequiredDataDefinitionDataSetsObject {
    
    // MARK: - Variables
    
    var name: String = ""
    var dataSetsDescription: String = ""
    
    var fields: [DataOfferRequiredDataDefinitionDataSetsFieldsObject] = []
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        name = ""
        dataSetsDescription = ""
        fields = []
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dictionary: Dictionary<String, JSON>) {
        
        if let tempName = dictionary["name"]?.string {
            
            name = tempName
        }
        
        if let tempDataSetsDescription = dictionary["description"]?.string {
            
            dataSetsDescription = tempDataSetsDescription
        }
        
        if let tempFields = dictionary["fields"]?.array {
            
            if tempFields.count > 0 {
                
                for field in tempFields {
                    
                    fields.append(DataOfferRequiredDataDefinitionDataSetsFieldsObject(dictionary: field.dictionaryValue))
                }
            }
        }
    }
}
