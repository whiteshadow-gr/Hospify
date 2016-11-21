//
//  JSONHelper.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 14/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

struct JSONHelper {
    
    static func createNotablesTableJSON() -> Dictionary<String, Any> {
        
        let authorFieldsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","id")),
            Dictionary.init(dictionaryLiteral: ("name","name")),
            Dictionary.init(dictionaryLiteral: ("name","nick")),
            Dictionary.init(dictionaryLiteral: ("name","phata")),
            Dictionary.init(dictionaryLiteral: ("name","photo_url"))
        ]
        
        let authorTableJSON: Dictionary = [
            
            "name": "authorv1",
            "source": "rumpel",
            "fields": authorFieldsJSON
            ] as [String : Any]
        
        let notesTable: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","message")),
            Dictionary.init(dictionaryLiteral: ("name","message")),
            Dictionary.init(dictionaryLiteral: ("name","kind")),
            Dictionary.init(dictionaryLiteral: ("name","created_time")),
            Dictionary.init(dictionaryLiteral: ("name","updated_time")),
            Dictionary.init(dictionaryLiteral: ("name","public_until")),
            Dictionary.init(dictionaryLiteral: ("name","shared")),
            Dictionary.init(dictionaryLiteral: ("name","shared_on"))
        ]
        
        let locationFieldsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","latitude")),
            Dictionary.init(dictionaryLiteral: ("name","longitude")),
            Dictionary.init(dictionaryLiteral: ("name","accuracy")),
            Dictionary.init(dictionaryLiteral: ("name","altitude")),
            Dictionary.init(dictionaryLiteral: ("name","locationv1")),
            Dictionary.init(dictionaryLiteral: ("name","altitude_accuracy")),
            Dictionary.init(dictionaryLiteral: ("name","heading")),
            Dictionary.init(dictionaryLiteral: ("name","speed")),
            Dictionary.init(dictionaryLiteral: ("name","shared"))
        ]
        
        let locationJSON: Dictionary = [
            
            "name": "locationv1",
            "source": "rumpel",
            "fields":locationFieldsJSON
            ] as [String : Any]
        
        let photosFieldsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","link")),
            Dictionary.init(dictionaryLiteral: ("name","source")),
            Dictionary.init(dictionaryLiteral: ("name","caption")),
            Dictionary.init(dictionaryLiteral: ("name","shared"))
        ]
        
        let photosJSON: Dictionary = [
            
            "name": "photov1",
            "source": "rumpel",
            "fields":photosFieldsJSON
            ] as [String : Any]
        
        let subTablesJSON: Array = [
            
            authorTableJSON,
            locationJSON,
            photosJSON
        ]
        
        let JSON: Dictionary = [
            
            "name": "notablesv1",
            "source": "rumpel",
            "fields":notesTable,
            "subTables":subTablesJSON
            ] as [String : Any]
        
        return JSON
    }    
    
//    class ApiDataRecord {
//        var id: Int?
//        var lastUpdated: NSDate
//        var name: String
//    }
//    class ApiDataValue {
//        var id: Int?
//        var value: String
//        var record: ApiDataRecord?
//    }
//    class ApiDataField {
//        var id: Int
//        var tableId: Int
//        var name: String
//        var values: [String]
//    }
//    class ApiDataTable {
//        var id: Int
//        var name: String
//        var source: String
//        var fields: [ApiDataField]?
//        var subTables: [ApiDataTable]?
//    }

    static func createJSONForPostingOnNotables(textToPost: String, hatTableStructure: Dictionary<String, Any>) -> Dictionary<String, Any> {
        
        var valuesArray: [Dictionary<String, Any>] = []
        
        let iso8601String = FormatterHelper.formatDateToISO(date: NSDate())
        
        let recordDictionary: Dictionary = [
            
            "name": iso8601String,
            "lastUpdated":iso8601String
        ] as [String : Any]
        
        for tableProperty in hatTableStructure {

            if tableProperty.key == "fields" {
                let tempDict = tableProperty.value as! JSON
                let tempArray = tempDict.array
                
                for dict in tempArray!{
                    
                    let messageFieldDictionary: Dictionary = [
                        
                        "id": dict.dictionary!["id"]!.number!,
                        "name":dict.dictionary!["name"]!.string!
                        ] as [String : Any]
                    
                    let messageDictionary: Dictionary = [
                        
                        "field": messageFieldDictionary,
                        "value": ""
                        ] as [String : Any]
                    
                    valuesArray.append(messageDictionary)
                    
                }
                
                print("fields")
            }else if tableProperty.key == "subTables"{
                
                let tempDict = tableProperty.value as! JSON
                let tempArray = tempDict.array
                
                for dict in tempArray!{
                   
                    let fieldsArray = dict["fields"].array!
                    
                    for field in fieldsArray{
                        
                        let messageFieldDictionary: Dictionary = [
                            
                            "id":field.dictionary!["id"]!.number!,
                            "name":field.dictionary!["name"]!.string!
                            ] as [String : Any]
                        
                        let messageDictionary: Dictionary = [
                            
                            "field": messageFieldDictionary,
                            "value": ""
                            ] as [String : Any]
                        
                        valuesArray.append(messageDictionary)
                    }
                }
            }
        }
        
        let arrayDictionary: Dictionary = [
            
            "record":recordDictionary,
            "values":valuesArray
            ] as [String : Any]
        
        return arrayDictionary
    }
    
    static func updateMessageOnJSON(file: JSON, message: String) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][0]["value"] = JSON(message)
        return jsonFile
    }
    
    static func updateVisibilityOfNoteOnJSON(file: JSON, isShared: Bool) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][5]["value"] = JSON(String(isShared))
        return jsonFile
    }
    
    static func updateKindOfNoteOnJSON(file: JSON, messageKind: String) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][1]["value"] = JSON(messageKind)
        return jsonFile
    }
    
    static func updateCreatedOnDateOfNoteOnJSON(file: JSON) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][2]["value"] = JSON(FormatterHelper.formatDateToISO(date: NSDate()))
        return jsonFile
    }
    
    static func updateUpdatedOnDateOfNoteOnJSON(file: JSON) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][3]["value"] = JSON(FormatterHelper.formatDateToISO(date: NSDate()))
        return jsonFile
    }
    
    static func updateSharedOnDateOfNoteOnJSON(file: JSON, socialString: String) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][4]["value"] = JSON(socialString)
        return jsonFile
    }
    
    static func updatePhataOnDateOfNoteOnJSON(file: JSON, phata: String) -> JSON {
        
        var jsonFile = file
        jsonFile["values"][22]["value"] = JSON(phata)
        return jsonFile
    }
}
