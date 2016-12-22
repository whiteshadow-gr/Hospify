/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import SwiftyJSON

// MARK: Struct

/// A struct for working with JSON files. Either creating or updating an existing JSON file
struct JSONHelper {
    
    // MARK: - Create JSON files functions
    
    /**
     Creates the notables JSON file
     
     - returns: Dictionary<String, Any>
     */
    static func createNotablesTableJSON() -> Dictionary<String, Any> {
        
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
    static func createJSONForPostingOnNotables(hatTableStructure: Dictionary<String, Any>) -> Dictionary<String, Any> {
        
        // init array
        var valuesArray: [Dictionary<String, Any>] = []
        
        // format date in an iso format
        let iso8601String = FormatterHelper.formatDateToISO(date: Date())
        
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
    static func updateMessageOnJSON(file: JSON, message: String) -> JSON {
        
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
    static func updateVisibilityOfNoteOnJSON(file: JSON, isShared: Bool) -> JSON {
        
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
    static func updateKindOfNoteOnJSON(file: JSON, messageKind: String) -> JSON {
        
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
    static func updateUpdatedOnDateOfNoteOnJSON(file: JSON, date: Date) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "updated_time" {
                
                jsonFile["values"][itemNumber]["value"] = JSON(FormatterHelper.formatDateToISO(date: date))
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
    static func updateCreatedOnDateOfNoteOnJSON(file: JSON, date: Date) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "created_time" {
                
                if jsonFile["values"][itemNumber]["value"] == "" {
                    
                    jsonFile["values"][itemNumber]["value"] = JSON(FormatterHelper.formatDateToISO(date: date))
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
    static func updateSharedOnDateOfNoteOnJSON(file: JSON, socialString: String) -> JSON {
        
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
    static func updateSharedForDurationOfNoteOnJSON(file: JSON, date: Date?) -> JSON {
        
        var jsonFile = file
        
        for itemNumber in 0...jsonFile["values"].count {
            
            if jsonFile["values"][itemNumber]["field"]["name"] == "public_until" {
                
                jsonFile["values"][itemNumber]["value"] = ""

                if let unwrappedDate = date {
                    
                    if unwrappedDate > Date() {
                        
                        jsonFile["values"][itemNumber]["value"] = JSON(FormatterHelper.formatDateToISO(date: unwrappedDate))
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
    static func updatePhataOfNoteOnJSON(file: JSON, phata: String) -> JSON {
        
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
    static func updateJSONFile(file: Dictionary<String, Any>, noteFile: NotesData) -> Dictionary<String, Any> {
        
        var jsonFile = JSON(file)
        
        //update message
        jsonFile = JSONHelper.updateMessageOnJSON(file: jsonFile, message: noteFile.data.message)
        //update kind
        jsonFile = JSONHelper.updateKindOfNoteOnJSON(file: jsonFile, messageKind: noteFile.data.kind)
        //update updated time
        jsonFile = JSONHelper.updateUpdatedOnDateOfNoteOnJSON(file: jsonFile, date: noteFile.lastUpdated)
        //update created time
        jsonFile = JSONHelper.updateCreatedOnDateOfNoteOnJSON(file: jsonFile, date: noteFile.data.createdTime)
        //update share duration time
        jsonFile = JSONHelper.updateSharedForDurationOfNoteOnJSON(file: jsonFile, date: noteFile.data.publicUntil)
        //update public
        jsonFile = JSONHelper.updateVisibilityOfNoteOnJSON(file: jsonFile, isShared: noteFile.data.shared)
        //update share on
        jsonFile = JSONHelper.updateSharedOnDateOfNoteOnJSON(file: jsonFile, socialString: noteFile.data.sharedOn)
        //update phata
        jsonFile = JSONHelper.updatePhataOfNoteOnJSON(file: jsonFile, phata: Helper.TheUserHATDomain())
        
        return jsonFile.dictionaryObject!
    }
}
