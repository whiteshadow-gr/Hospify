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

class TwitterDataTweetsSocialFeedObject {

    var source: String = ""
    var truncated: String = ""
    var retweetCount: String = ""
    var retweeted: String = ""
    var favoriteCount: String = ""
    var id: String = ""
    var text: String = ""
    var createdAt: Date? = nil
    var favorited: String = ""
    var lang: String = ""
    var user: TwitterDataTweetsUsersSocialFeedObject = TwitterDataTweetsUsersSocialFeedObject()
    
    init() {
        
        source = ""
        truncated = ""
        retweetCount = ""
        retweeted = ""
        favoriteCount = ""
        id = ""
        text = ""
        createdAt = nil
        favorited = ""
        lang = ""
        user = TwitterDataTweetsUsersSocialFeedObject()
    }
    
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempSource = dictionary["source"]?.stringValue {
            
            source = tempSource
        }
        if let tempTruncated = dictionary["truncated"]?.stringValue {
            
            truncated = tempTruncated
        }
        if let tempRetweetCount = dictionary["retweet_count"]?.stringValue {
            
            retweetCount = tempRetweetCount
        }
        if let tempRetweeted = dictionary["retweeted"]?.stringValue {
            
            retweeted = tempRetweeted
        }
        if let tempFavouriteCount = dictionary["favorite_count"]?.stringValue {
            
            favoriteCount = tempFavouriteCount
        }
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
        if let tempText = dictionary["text"]?.stringValue {
            
            text = tempText
        }
        if let tempCreatedAt = dictionary["created_at"]?.stringValue {
            
            createdAt = FormatterHelper.formatStringToDate(string: tempCreatedAt)
        }
        if let tempFavorited = dictionary["favorited"]?.stringValue {
            
            favorited = tempFavorited
        }
        if let tempLang = dictionary["lang"]?.stringValue {
            
            lang = tempLang
        }
        if let tempUser = dictionary["user"]?.dictionaryValue {
            
            user = TwitterDataTweetsUsersSocialFeedObject(from: tempUser)
        }
    }
}
