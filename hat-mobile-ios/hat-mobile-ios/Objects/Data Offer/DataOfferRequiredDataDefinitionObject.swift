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

struct DataOfferRequiredDataDefinitionObject {
    
    // MARK: - Variables
    
    var source: String = ""
    
    var dataSets: [DataOfferRequiredDataDefinitionDataSetsObject] = []
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        source = ""
        dataSets = []
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dictionary: Dictionary<String, JSON>) {
        
        if let tempSource = dictionary["source"]?.string {
            
            source = tempSource
        }
        
        if let tempDataSets = dictionary["datasets"]?.array {
            
            if tempDataSets.count > 0 {
                
                for dataSet in tempDataSets {
                    
                    dataSets.append(DataOfferRequiredDataDefinitionDataSetsObject(dictionary: dataSet.dictionaryValue))
                }
            }
        }
    }
}
