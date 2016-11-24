//
//  NotesData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

struct NotesData {

    var id: Int
    var name: String
    var lastUpdated: Date
    var data: NotablesData
    
    init() {
        
        id = -2
        name = ""
        lastUpdated = Date()
        data = NotablesData.init()
    }
    
    init(dict: Dictionary<String, Any>) {
        
        let tempID: JSON = dict["id"] as! JSON
        let tempname: JSON = dict["name"] as! JSON
        let tempLastUpdated: JSON = dict["lastUpdated"] as! JSON
        let tempData: JSON = dict["data"] as! JSON

        id = tempID.int!
        name = tempname.string!
        lastUpdated = FormatterHelper.formatStringToDate(string: tempLastUpdated.string!)
        data = NotablesData.init(dict: tempData["notablesv1"].dictionary!)
    }
}
