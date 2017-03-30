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

public struct HATJSONHelper {
        
    // MARK: - Create JSON files functions
    
    /**
     Creates the notables JSON file
     
     - returns: Dictionary<String, Any>
     */
    public static func createNotablesTableJSON() -> Dictionary<String, Any> {
        
        // create the author table fields
        let authorFieldsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","id")),
            Dictionary.init(dictionaryLiteral: ("name","name")),
            Dictionary.init(dictionaryLiteral: ("name","nick")),
            Dictionary.init(dictionaryLiteral: ("name","phata")),
            Dictionary.init(dictionaryLiteral: ("name","photo_url"))
        ]
        
        // create the author table
        let authorTableJSON: Dictionary = [
            
            "name": "authorv1",
            "source": "rumpel",
            "fields": authorFieldsJSON
            ] as [String : Any]
        
        // create the notes table
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
        
        // create the location table fields
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
        
        // create the location table
        let locationJSON: Dictionary = [
            
            "name": "locationv1",
            "source": "rumpel",
            "fields":locationFieldsJSON
            ] as [String : Any]
        
        // create the photos table field
        let photosFieldsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","link")),
            Dictionary.init(dictionaryLiteral: ("name","source")),
            Dictionary.init(dictionaryLiteral: ("name","caption")),
            Dictionary.init(dictionaryLiteral: ("name","shared"))
        ]
        
        // create the photos table
        let photosJSON: Dictionary = [
            
            "name": "photov1",
            "source": "rumpel",
            "fields":photosFieldsJSON
            ] as [String : Any]
        
        // add the created tables in as subarrays
        let subTablesJSON: Array = [
            
            authorTableJSON,
            locationJSON,
            photosJSON
        ]
        
        // create the final json file
        let JSON: Dictionary = [
            
            "name": "notablesv1",
            "source": "rumpel",
            "fields":notesTable,
            "subTables":subTablesJSON
            ] as [String : Any]
        
        // return the json file
        return JSON
    }
    
    /**
     Creates the json file to update a note
     
     - parameter hatTableStructure: Dictionary<String, Any>
     - returns: Dictionary<String, Any>
     */
    public static func createJSONForPostingOnNotables(hatTableStructure: Dictionary<String, Any>) -> Dictionary<String, Any> {
        
        // init array
        var valuesArray: [Dictionary<String, Any>] = []
        
        // format date in an iso format
        let iso8601String = HATFormatterHelper.formatDateToISO(date: Date())
        
        // the record json fields
        let recordDictionary: Dictionary = [
            
            "name": iso8601String,
            "lastUpdated":iso8601String
            ] as [String : Any]
        
        // for each json file in hatTableStructure
        for tableProperty in hatTableStructure {
            
            // check for the fields
            if tableProperty.key == "fields" {
                
                // save as a dict in JSON format
                let tempDict = tableProperty.value as! JSON
                // get the array from the dictionary
                let tempArray = tempDict.array
                
                // for each dictionary in the array
                for dict in tempArray! {
                    
                    // create the message fields
                    let messageFieldDictionary: Dictionary = [
                        
                        "id": Int(dict.dictionary!["id"]!.number!),
                        "name":dict.dictionary!["name"]!.string!
                        ] as [String : Any]
                    
                    // create the message table
                    let messageDictionary: Dictionary = [
                        
                        "field": messageFieldDictionary,
                        "value": ""
                        ] as [String : Any]
                    
                    valuesArray.append(messageDictionary)
                }
                
                print("fields")
                // find subtables
            } else if tableProperty.key == "subTables" {
                
                // save as a dict in JSON format
                let tempDict = tableProperty.value as! JSON
                // get the array from the dictionary
                let tempArray = tempDict.array
                
                // for each dictionary in the array
                for dict in tempArray! {
                    
                    // get the table
                    let fieldsArray = dict["fields"].array!
                    
                    // for each field in the tables
                    for field in fieldsArray {
                        
                        // create the message field
                        let messageFieldDictionary: Dictionary = [
                            
                            "id":Int(field.dictionary!["id"]!.number!),
                            "name":field.dictionary!["name"]!.string!
                            ] as [String : Any]
                        
                        // create the message table
                        let messageDictionary: Dictionary = [
                            
                            "field": messageFieldDictionary,
                            "value": ""
                            ] as [String : Any]
                        
                        valuesArray.append(messageDictionary)
                    }
                }
            }
        }
        
        // add everything in a dictionary
        let arrayDictionary: Dictionary = [
            
            "record":recordDictionary,
            "values":valuesArray
            ] as [String : Any]
        
        // return the dictionary
        return arrayDictionary
    }
    
    // MARK: - Update JSON file functions
    
    /**
     Updates the message of the note json file
     
     - parameter file: The json file to update
     - parameter message: The message to add to the note
     
     - returns: JSON
     */
    public static func updateMessageOnJSON(file: JSON, message: String) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "message" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(message)
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the visibility of the note json file
     
     - parameter file: The json file to update
     - parameter isShared: the boolean value as a string indicating if the note is shared
     
     - returns: JSON
     */
    public static func updateVisibilityOfNoteOnJSON(file: JSON, isShared: Bool) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "shared" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(String(isShared))
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the kind of the note json file
     
     - parameter file: The json file to update
     - parameter messageKind: the kind of the message. 3 kinds available, note, blog, list
     
     - returns: JSON
     */
    public static func updateKindOfNoteOnJSON(file: JSON, messageKind: String) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "kind" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(messageKind)
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the updated date of the note json file
     
     - parameter file: The json file to update
     - parameter date: the updated date
     
     - returns: JSON
     */
    public static func updateUpdatedOnDateOfNoteOnJSON(file: JSON) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "updated_time" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(HATFormatterHelper.formatDateToISO(date: Date()))
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the created date of the note json file if needed
     
     - parameter file: The json file to update
     - parameter date: the created date
     
     - returns: JSON
     */
    public static func updateCreatedOnDateOfNoteOnJSON(file: JSON, date: Date) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "created_time" {
                
                if jsonFile["values"][itemNumber]["value"] == "" {
                    
                    jsonFile["values"][itemNumber]["value"] = JSON(HATFormatterHelper.formatDateToISO(date: date))
                }
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the social media that this note is shared in the json file
     
     - parameter file: The json file to update
     - parameter socialString: Coma seperated string indicating the social media that this note will be shared into
     
     - returns: JSON
     */
    public static func updateSharedOnDateOfNoteOnJSON(file: JSON, socialString: String) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "shared_on" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(socialString)
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the public until date of the note json file
     
     - parameter file: The json file to update
     - parameter parameter date: the shared for duration date
     
     - returns: JSON
     */
    public static func updateSharedForDurationOfNoteOnJSON(file: JSON, date: Date?) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "public_until" {
                
                jsonFile["values"][itemNumber]["value"] = ""
                
                if let unwrappedDate = date {
                    
                    if unwrappedDate > Date() {
                        
                        jsonFile["values"][itemNumber]["value"] = JSON(HATFormatterHelper.formatDateToISO(date: unwrappedDate))
                    }
                }
            }
        }
        
        return jsonFile
    }
    
    /**
     Updates the phata of the note json file
     
     - parameter file: The json file to update
     - parameter phata: The user's phata
     
     - returns: JSON
     */
    public static func updatePhataOfNoteOnJSON(file: JSON, phata: String) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "phata" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(phata)
            }
        }
        
        return jsonFile
    }
    
    /**
     Adds all the info about the note we want to add to the JSON file
     
     - parameter file: The JSON file in a Dictionary<String, Any>
     - returns: Dictionary<String, Any>
     */
    public static func updateJSONFile(file: Dictionary<String, Any>, noteFile: HATNotesData, userDomain: String) -> Dictionary<String, Any> {
        
        var jsonFile = JSON(file)
        
        //update message
        jsonFile = HATJSONHelper.updateMessageOnJSON(file: jsonFile, message: noteFile.data.message)
        //update kind
        jsonFile = HATJSONHelper.updateKindOfNoteOnJSON(file: jsonFile, messageKind: noteFile.data.kind)
        //update updated time
        jsonFile = HATJSONHelper.updateUpdatedOnDateOfNoteOnJSON(file: jsonFile)
        //update created time
        jsonFile = HATJSONHelper.updateCreatedOnDateOfNoteOnJSON(file: jsonFile, date: noteFile.data.createdTime)
        //update share duration time
        jsonFile = HATJSONHelper.updateSharedForDurationOfNoteOnJSON(file: jsonFile, date: noteFile.data.publicUntil)
        //update public
        jsonFile = HATJSONHelper.updateVisibilityOfNoteOnJSON(file: jsonFile, isShared: noteFile.data.shared)
        //update share on
        jsonFile = HATJSONHelper.updateSharedOnDateOfNoteOnJSON(file: jsonFile, socialString: noteFile.data.sharedOn)
        //update phata
        jsonFile = HATJSONHelper.updatePhataOfNoteOnJSON(file: jsonFile, phata: userDomain)
        
        return jsonFile.dictionaryObject!
    }
    
    // MARK: - Create JSON for file uploading
    
    /**
     Creates the json file to purchase a HAT
     
     - parameter purchaseModel: The purchase model with all the necessary values
     - returns: A Dictionary <String, Any>
     */
    static func createFileUploadingJSONFrom(fileName: String) -> Dictionary <String, Any> {
        
        // the final JSON file to be returned
        let json: Dictionary = [
            
            "name" : fileName,
            "source" : "iPhone"
            ] as [String : Any]
        
        return json
    }
    
}
