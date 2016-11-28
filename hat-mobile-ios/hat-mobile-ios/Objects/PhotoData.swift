//
//  PhotoData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

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
        
        shared = false
        link = dict["link"]!
        source = dict["source"]!
        caption = dict["caption"]!
        
        // check if shared exists and if is empty
        if let tempShared = dict["shared"] {
            
            if tempShared != "" {
                
                shared = true
            }
        }
    }
}
