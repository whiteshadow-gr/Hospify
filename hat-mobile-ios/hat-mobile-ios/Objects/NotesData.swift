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
        
        id = -1
        name = ""
        lastUpdated = Date()
        data = NotablesData.init()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {

        id = (dict["id"]?.int!)!
        name = (dict["name"]?.string!)!
        lastUpdated = FormatterHelper.formatStringToDate(string: (dict["lastUpdated"]?.string!)!)
        data = NotablesData.init(dict: (dict["data"]?["notablesv1"].dictionary!)!)
    }
}
