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

// MARK: Struct

/// A struct representing the location table received from JSON
struct PhotoData {
    
    // MARK: - Variables

    /// the link to the photo
    var link: String
    /// the source of the photo
    var source: String
    /// the caption of the photo
    var caption: String
    
    /// if photo is shared
    var shared: Bool
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        link = ""
        source = ""
        caption = ""
        shared = false
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, String>) {
        
        self.init()
        
        // check if shared exists and if is empty
        if let tempShared = dict["shared"] {
            
            if tempShared != "" {
                
                shared = true
            }
        }
        
        if let tempLink = dict["link"] {
            
            link = tempLink
        }
        
        if let tempSource = dict["source"] {
            
            source = tempSource
        }
        
        if let tempCaption = dict["caption"] {
            
            caption = tempCaption
        }
    }
}
