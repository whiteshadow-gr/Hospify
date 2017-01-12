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

struct DataPlugDataDefinitionObject {

    var source: String = ""
    var dataSets: [DataPlugDataSetObject] = []
    
    init() {
        
        source = ""
        dataSets = []
    }
    
    init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempSource = (dict["source"]?.stringValue) {
            
            source = tempSource
        }
        if let tempDataSets = (dict["datasets"]?.dictionary) {
            
            dataSets = [DataPlugDataSetObject(dict: tempDataSets)]
        }
    }
}
