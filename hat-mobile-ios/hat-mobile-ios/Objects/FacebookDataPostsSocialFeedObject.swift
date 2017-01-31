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

class FacebookDataPostsSocialFeedObject {

    var from: FacebookDataPostsFromSocialFeedObject = FacebookDataPostsFromSocialFeedObject()
    var id: String = ""
    var statusType: String = ""
    var privacy: FacebookDataPostsPrivacySocialFeedObject = FacebookDataPostsPrivacySocialFeedObject()
    var updatedTime: Date? = nil
    var type: String = ""
    var createdTime: Date? = nil
    var message: String = ""
    
    var fullPicture: String = ""
    var link: String = ""
    var picture: String = ""
    var story: String = ""
    var name: String = ""
    var description: String = ""
    var objectID: String = ""
    var application: FacebookDataPostsApplicationSocialFeedObject = FacebookDataPostsApplicationSocialFeedObject()
    var caption: String = ""
    
    init() {
        
        from = FacebookDataPostsFromSocialFeedObject()
        id = ""
        statusType = ""
        privacy = FacebookDataPostsPrivacySocialFeedObject()
        updatedTime = nil
        type = ""
        createdTime = nil
        message = ""
        
        fullPicture = ""
        link = ""
        picture = ""
        story = ""
        name = ""
        description = ""
        objectID = ""
        application = FacebookDataPostsApplicationSocialFeedObject()
        caption = ""
    }
    
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempFrom = dictionary["from"]?.dictionaryValue {
            
            from = FacebookDataPostsFromSocialFeedObject(from: tempFrom)
        }
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
        if let tempStatusType = dictionary["status_type"]?.stringValue {
            
            statusType = tempStatusType
        }
        if let tempPrivacy = dictionary["privacy"]?.dictionaryValue {
            
            privacy = FacebookDataPostsPrivacySocialFeedObject(from: tempPrivacy)
        }
        if let tempUpdateTime = dictionary["updated_time"]?.stringValue {
            
            updatedTime = FormatterHelper.formatStringToDate(string: tempUpdateTime)
        }
        if let tempType = dictionary["type"]?.stringValue {
            
            type = tempType
        }
        if let tempCreatedTime = dictionary["created_time"]?.stringValue {
            
            createdTime = FormatterHelper.formatStringToDate(string: tempCreatedTime)
        }
        if let tempMessage = dictionary["message"]?.stringValue {
            
            message = tempMessage
        }
        
        if let tempFullPicture = dictionary["full_picture"]?.stringValue {
            
            fullPicture = tempFullPicture
        }
        if let tempLink = dictionary["link"]?.stringValue {
            
            link = tempLink
        }
        if let tempPicture = dictionary["picture"]?.stringValue {
            
            picture = tempPicture
        }
        if let tempStory = dictionary["story"]?.stringValue {
            
            story = tempStory
        }
        if let tempDescription = dictionary["description"]?.stringValue {
            
            description = tempDescription
        }
        if let tempObjectID = dictionary["object_id"]?.stringValue {
            
            objectID = tempObjectID
        }
        if let tempApplication = dictionary["application"]?.dictionaryValue {
            
            application = FacebookDataPostsApplicationSocialFeedObject(from: tempApplication)
        }
        if let tempCaption = dictionary["caption"]?.stringValue {
            
            caption = tempCaption
        }
    }
}
