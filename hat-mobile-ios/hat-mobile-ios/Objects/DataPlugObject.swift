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

/// A struct representing the outer data plug JSON format
struct DataPlugObject {
    
    // MARK: - Variables

    /// The unique id of the data plug
    var uuid: String = ""
    /// The name of the data plug
    var name: String = ""
    /// The description of the data plug
    var description: String = ""
    /// The url of the data plug
    var url: String = ""
    /// The url of the image, asset, of the data plug
    var illustrationUrl: String = ""
    /// The url of the image, asset, of the data plug
    var showCheckMark: Bool = false
    
    /// The owner object of the data plug
    var owner: DataPlugOwnerObject = DataPlugOwnerObject()
    /// The data definition object of the data plug
    var dataDefinition: DataPlugDataDefinitionObject = DataPlugDataDefinitionObject()
    /// The rating object of the data plug
    var rating: DataPlugRatingObject = DataPlugRatingObject()
    
    /// The created date of the data plug
    var created: Date? = nil
    
    /// The status of the data plug, if enabled is approved
    var approved: Bool = false

    /// The users using the data plug
    var users: Int = -1
    
    // MARK: - Initializers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        uuid = ""
        name = ""
        description = ""
        url = ""
        illustrationUrl = ""
        showCheckMark = false
        
        owner = DataPlugOwnerObject()
        dataDefinition = DataPlugDataDefinitionObject()
        rating = DataPlugRatingObject()
        
        created = nil
        
        approved = false

        users = -1
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>){
        
        self.init()
        
        if let tempUuid = (dict["uuid"]?.stringValue) {
            
            uuid = tempUuid
        }
        if let tempDescription = (dict["description"]?.stringValue) {
            
            description = tempDescription
        }
        if let tempName = (dict["name"]?.stringValue) {
            
            name = tempName
        }
        if let tempUrl = (dict["url"]?.stringValue) {
            
            url = tempUrl
        }
        if let tempIllustrationUrl = (dict["illustrationUrl"]?.stringValue) {
            
            illustrationUrl = tempIllustrationUrl
        }
        
        if let tempOwner = (dict["owner"]?.dictionaryValue) {
            
            owner = DataPlugOwnerObject(dict: tempOwner)
        }
        if let tempDefinition = (dict["dataDefinition"]?.dictionaryValue) {
            
            dataDefinition = DataPlugDataDefinitionObject(dict: tempDefinition)
        }
        if let tempRating = (dict["rating"]?.dictionaryValue) {
            
            rating = DataPlugRatingObject(dict: tempRating)
        }
        
        if let tempApproved = (dict["approved"]?.boolValue) {
            
            approved = tempApproved
        }
        
        if let tempCreated = (dict["created"]?.intValue) {
            
            created = FormatterHelper.formatStringToDate(string: String(tempCreated))
        }
        
        if let tempUsers = (dict["users"]?.intValue) {
            
            users = tempUsers
        }
    }
}
