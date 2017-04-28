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
    
    // MARK: - Create JSON for purchasing
    
    /**
     Creates the json file to purchase a HAT
     
     - parameter purchaseModel: The purchase model with all the necessary values
     - returns: A Dictionary <String, Any>
     */
    static func createPurchaseJSONFrom(purchaseModel: PurchaseModel) -> Dictionary <String, Any> {
        
        // hat table dictionary
        let hat: Dictionary =  [
            
            "address" : purchaseModel.address,
            "termsAgreed" : purchaseModel.termsAgreed,
            "country" : purchaseModel.country
        ] as [String : Any]
        
        // user table dictionary
        let user: Dictionary =  [
            
            "firstName" : purchaseModel.firstName,
            "lastName" : purchaseModel.lastName,
            "password" : purchaseModel.password,
            "termsAgreed" : purchaseModel.termsAgreed,
            "nick" : purchaseModel.nick,
            "email" : purchaseModel.email
        ] as [String : Any]
        
        // items table dictionary
        let items: Dictionary = [
        
            "sku": purchaseModel.sku,
            "quantity": 1
        ] as [String : Any]
        
        var purchase: Dictionary<String, Any> = [:]
        if purchaseModel.token != "" {
            
            // purchase table dictionary
            purchase = [
                
                "stripePaymentToken" : purchaseModel.token,
                "items" : [items]
                ]
        } else {
            
            // purchase table dictionary
            purchase = [
                
                "items" : [items]
                ]
        }
        
        // the final JSON file to be returned
        let json: Dictionary = [
        
            "purchase" : purchase,
            "user" : user,
            "hat" : hat,
            "password" : purchaseModel.password
        ] as [String : Any]
        
        return json
    }

    /**
     Creates the profile JSON file
     
     - returns: Dictionary<String, Any>
     */
    public static func createProfileTableJSON() -> Dictionary<String, Any> {
        
        let fieldsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let facebookProfilePhoto: Any = [
            
            "name" : "fb_profile_photo",
            "source" : "rumpel",
            "fields" : fieldsJSON
        ]
        
        let personalJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","title")),
            Dictionary.init(dictionaryLiteral: ("name","first_name")),
            Dictionary.init(dictionaryLiteral: ("name","middle_name")),
            Dictionary.init(dictionaryLiteral: ("name","last_name")),
            Dictionary.init(dictionaryLiteral: ("name","preferred_name")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let personal: Any = [
            
            "name" : "personal",
            "source" : "rumpel",
            "fields" : personalJSON
        ]
        
        let nickJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","name")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let nick: Any = [
            
            "name" : "nick",
            "source" : "rumpel",
            "fields" : nickJSON
        ]
        
        let birthJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","date")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let birth: Any = [
            
            "name" : "birth",
            "source" : "rumpel",
            "fields" : birthJSON
        ]
        
        let genderJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","type")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let gender: Any = [
            
            "name" : "gender",
            "source" : "rumpel",
            "fields" : genderJSON
        ]
        
        let ageJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","group")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let age: Any = [
            
            "name" : "age",
            "source" : "rumpel",
            "fields" : ageJSON
        ]
        
        let emailJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","value")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let primaryEmail: Any = [
            
            "name" : "primary_email",
            "source" : "rumpel",
            "fields" : emailJSON
        ]
        
        let alternativeEmail: Any = [
            
            "name" : "alternative_email",
            "source" : "rumpel",
            "fields" : emailJSON
        ]
        
        let phoneJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","no")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let homePhone: Any = [
            
            "name" : "home_phone",
            "source" : "rumpel",
            "fields" : phoneJSON
        ]
        
        let mobile: Any = [
            
            "name" : "mobile",
            "source" : "rumpel",
            "fields" : phoneJSON
        ]
        
        let addressDetailsJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","no")),
            Dictionary.init(dictionaryLiteral: ("name","street")),
            Dictionary.init(dictionaryLiteral: ("name","postcode")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let addressDetails: Any = [
            
            "name" : "address_details",
            "source" : "rumpel",
            "fields" : addressDetailsJSON
        ]
        
        let addressGlobalJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","city")),
            Dictionary.init(dictionaryLiteral: ("name","county")),
            Dictionary.init(dictionaryLiteral: ("name","country")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let addressGlobal: Any = [
            
            "name" : "address_global",
            "source" : "rumpel",
            "fields" : addressGlobalJSON
        ]
        
        let socialJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","link")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let website: Any = [
            
            "name" : "website",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let blog: Any = [
            
            "name" : "blog",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let facebook: Any = [
            
            "name" : "facebook",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let twitter: Any = [
            
            "name" : "twitter",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let google: Any = [
            
            "name" : "google",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let youtube: Any = [
            
            "name" : "youtube",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let linkedIn: Any = [
            
            "name" : "linkedin",
            "source" : "rumpel",
            "fields" : socialJSON
        ]
        
        let aboutJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","title")),
            Dictionary.init(dictionaryLiteral: ("name","body")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let about: Any = [
            
            "name" : "about",
            "source" : "rumpel",
            "fields" : aboutJSON
        ]
        
        let emergencyContactJSON: Array = [
            
            Dictionary.init(dictionaryLiteral: ("name","first_name")),
            Dictionary.init(dictionaryLiteral: ("name","last_name")),
            Dictionary.init(dictionaryLiteral: ("name","mobile")),
            Dictionary.init(dictionaryLiteral: ("name","relationship")),
            Dictionary.init(dictionaryLiteral: ("name","private"))
        ]
        
        let emergencyContact: Any = [
            
            "name" : "emergency_contact",
            "source" : "rumpel",
            "fields" : emergencyContactJSON
        ]
        
        let subtables: Array = [
            
            facebookProfilePhoto,
            personal,
            nick,
            birth,
            gender,
            age,
            primaryEmail,
            alternativeEmail,
            homePhone,
            mobile,
            addressDetails,
            addressGlobal,
            website,
            blog,
            facebook,
            twitter,
            google,
            linkedIn,
            youtube,
            emergencyContact,
            about
        ]
        
        // create the final json file
        let JSON: Dictionary = [
            
            "name": "profile",
            "source": "rumpel",
            "fields":fieldsJSON,
            "subTables":subtables
        ] as [String : Any]
        
        // return the json file
        return JSON
    }
}
