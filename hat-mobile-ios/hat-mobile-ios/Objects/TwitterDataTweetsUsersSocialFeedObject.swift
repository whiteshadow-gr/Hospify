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

class TwitterDataTweetsUsersSocialFeedObject {

    var friendsCount: String = ""
    var id: String = ""
    var lang: String = ""
    var listedCount: String = ""
    var favouritesCount: String = ""
    var statusesCount: String = ""
    var screenName: String = ""
    var name: String = ""
    var followersCount: String = ""
    
    init() {
        
        friendsCount = ""
        id = ""
        lang = ""
        listedCount = ""
        favouritesCount = ""
        statusesCount = ""
        screenName = ""
        name = ""
        followersCount = ""
    }
    
    convenience init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempFriendsCount = dictionary["friends_count"]?.stringValue {
            
            friendsCount = tempFriendsCount
        }
        if let tempID = dictionary["id"]?.stringValue {
            
            id = tempID
        }
        if let tempLang = dictionary["lang"]?.stringValue {
            
            lang = tempLang
        }
        if let tempListedCount = dictionary["listed_count"]?.stringValue {
            
            listedCount = tempListedCount
        }
        if let tempFavouritesCount = dictionary["favorites_count"]?.stringValue {
            
            favouritesCount = tempFavouritesCount
        }
        if let tempStatusesCount = dictionary["statuses_count"]?.stringValue {
            
            statusesCount = tempStatusesCount
        }
        if let tempScreenName = dictionary["screen_name"]?.stringValue {
            
            screenName = tempScreenName
        }
        if let tempName = dictionary["name"]?.stringValue {
            
            name = tempName
        }
        if let tempFollowersCount = dictionary["followers_count"]?.stringValue {
            
            followersCount = tempFollowersCount
        }
    }
}
