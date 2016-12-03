//
//  NotesData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

// MARK: Struct

/// A struct representing the outer notes JSON format
struct NotesData {
    
    // MARK: - Variables
    
    /// the note id
    var id: Int
    /// the name of the note
    var name: String
    /// the last updated date of the note
    var lastUpdated: Date
    /// the data of the note, such as tables about the author, location, photo etc
    var data: NotablesData
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        id = 0
        name = ""
        lastUpdated = Date()
        data = NotablesData.init()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {

        id = 0
        name = ""
        lastUpdated = Date()
        data = NotablesData.init()
        
        if let tempID = dict["id"]?.int {
            
            id = tempID
        }
        if let tempName = dict["name"]?.string {
            
            name = tempName
        }
        if let tempLastUpdated = dict["lastUpdated"]?.string {
            
            lastUpdated = FormatterHelper.formatStringToDate(string: tempLastUpdated)
        }
        if let tempData = dict["data"]?["notablesv1"].dictionary {
            
            data = NotablesData.init(dict: tempData)
        }
    }
}
