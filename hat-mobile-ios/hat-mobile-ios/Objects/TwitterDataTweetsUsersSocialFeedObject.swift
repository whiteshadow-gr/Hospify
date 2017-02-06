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

// MARK: Class

/// A class representing the user's info of a tweet
class TwitterDataTweetsUsersSocialFeedObject {
    
    // MARK: - Variables

    /// The user's friend count
    var friendsCount: String = ""
    /// The user's id
    var id: String = ""
    /// The user's language
    var lang: String = ""
    /// The user's listed count
    var listedCount: String = ""
    /// The user's favourites count
    var favouritesCount: String = ""
    /// The user's statuses count
    var statusesCount: String = ""
    /// The user's screen name
    var screenName: String = ""
    /// The user's name
    var name: String = ""
    /// The user's followers count
    var followersCount: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
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
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
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
