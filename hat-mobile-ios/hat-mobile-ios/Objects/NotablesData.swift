//
//  NotablesData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

struct NotablesData {

    var authorData: AuthorData
    var createdTime: Date
    var shared: Bool
    //???
    var sharedOn: String
    var photoData: PhotoData
    var locationData: LocationData
    var message: String
    //??
    var publicUntil: Date
    var updatedTime: Date
    var kind: String
    
    init() {
        
        authorData = AuthorData.init()
        createdTime = Date()
        shared = false
        sharedOn = ""
        photoData = PhotoData.init()
        locationData = LocationData.init()
        message = ""
        publicUntil = Date()
        updatedTime = Date()
        kind = ""
    }
    
    init(dict: Dictionary<String, JSON>) {

        if let tempAuthorData: JSON = dict["authorv1"] {
            
             authorData = AuthorData.init(dict: tempAuthorData.dictionary!)
        } else {
            
            authorData = AuthorData.init()
        }
        
        if let tempPhotoData: JSON = dict["photov1"] {
            
            photoData = PhotoData.init(dict: tempPhotoData.dictionaryObject! as! Dictionary<String, String>)
        } else {
            
            photoData = PhotoData.init()
        }
        
        if let tempLocationData: JSON = dict["locationv1"] {
            
            locationData = LocationData.init(dict: tempLocationData.dictionary!)
        } else {
            
            locationData = LocationData.init()
        }
        
        let tempShared: JSON = dict["shared"]!
        let tempSharedOn: JSON = dict["shared_on"]!
        let tempMessage: JSON = dict["message"]!
        let tempPublicUntil: JSON = dict["public_until"]!
        let tempUpdatedTime: JSON = dict["updated_time"]!
        let tempKind: JSON = dict["kind"]!
        
        createdTime = FormatterHelper.formatStringToDate(string: (dict["created_time"]!).string!)
        shared = Bool(tempShared.string!)!
        sharedOn = tempSharedOn.string!
        message = tempMessage.string!
        publicUntil = FormatterHelper.formatStringToDate(string: tempPublicUntil.string!)
        updatedTime = FormatterHelper.formatStringToDate(string: tempUpdatedTime.string!)
        kind = tempKind.string!
    }
}
