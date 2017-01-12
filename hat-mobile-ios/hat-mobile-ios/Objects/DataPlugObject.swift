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

struct DataPlugObject {

    var uuid: String = ""
    var owner: DataPlugOwnerObject = DataPlugOwnerObject()
    var created: Date? = nil
    var name: String = ""
    var description: String = ""
    var dataDefinition: DataPlugDataDefinitionObject = DataPlugDataDefinitionObject()
    var url: String = ""
    var illustrationUrl: String = ""
    var approved: Bool = false
    var rating: DataPlugRatingObject = DataPlugRatingObject()
    var users: Int = -1
    
    init() {
        
        uuid = ""
        owner = DataPlugOwnerObject()
        created = nil
        name = ""
        description = ""
        dataDefinition = DataPlugDataDefinitionObject()
        url = ""
        illustrationUrl = ""
        approved = false
        rating = DataPlugRatingObject()
        users = -1
    }
    
    init(dict: Dictionary<String, JSON>){
        
        self.init()
        
        if let tempUuid = (dict["uuid"]?.stringValue) {
            
            uuid = tempUuid
        }
        if let tempOwner = (dict["owner"]?.dictionaryValue) {
            
            owner = DataPlugOwnerObject(dict: tempOwner)
        }
        if let tempCreated = (dict["created"]?.intValue) {
            
            created = FormatterHelper.formatStringToDate(string: String(tempCreated))
        }
        if let tempName = (dict["name"]?.stringValue) {
            
            name = tempName
        }
        if let tempDescription = (dict["description"]?.stringValue) {
            
            description = tempDescription
        }
        if let tempDefinition = (dict["dataDefinition"]?.dictionaryValue) {
            
            dataDefinition = DataPlugDataDefinitionObject(dict: tempDefinition)
        }
        if let tempUrl = (dict["url"]?.stringValue) {
            
            url = tempUrl
        }
        if let tempIllustrationUrl = (dict["illustrationUrl"]?.stringValue) {
            
            illustrationUrl = tempIllustrationUrl
        }
        if let tempApproved = (dict["approved"]?.boolValue) {
            
            approved = tempApproved
        }
        if let tempRating = (dict["rating"]?.dictionaryValue) {
            
            rating = DataPlugRatingObject(dict: tempRating)
        }
        if let tempUsers = (dict["users"]?.intValue) {
            
            users = tempUsers
        }
    }
}
