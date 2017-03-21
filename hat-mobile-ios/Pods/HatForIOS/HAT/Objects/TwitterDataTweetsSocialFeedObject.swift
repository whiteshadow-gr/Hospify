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

/// A class representing the actual data of the tweet
public class TwitterDataTweetsSocialFeedObject: Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: TwitterDataTweetsSocialFeedObject, rhs: TwitterDataTweetsSocialFeedObject) -> Bool {
        
        return (lhs.source == rhs.source && lhs.truncated == rhs.truncated && lhs.retweetCount == rhs.retweetCount
            && lhs.retweeted == rhs.retweeted && lhs.favoriteCount == rhs.favoriteCount && lhs.id == rhs.id && lhs.text == rhs.text && lhs.favorited == rhs.favorited && lhs.lang == rhs.lang)
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func <(lhs: TwitterDataTweetsSocialFeedObject, rhs: TwitterDataTweetsSocialFeedObject) -> Bool {
        
        if lhs.createdAt != nil && rhs.createdAt != nil {
            
            return lhs.createdAt! < rhs.createdAt!
        } else if lhs.createdAt != nil && rhs.createdAt == nil {
            
            return false
        } else {
            
            return true
        }
    }
    
    // MARK: - Variables

    /// The source of the tweet
    var source: String = ""
    /// Shows if the tweet is truncated or not
    var truncated: String = ""
    /// Shows the retweet count
    var retweetCount: String = ""
    /// Shows if the tweet has been retweeted
    var retweeted: String = ""
    /// Shows the tweet's favourites count
    var favoriteCount: String = ""
    /// Shows the tweet's id
    var id: String = ""
    /// Shows the text of the tweet
    var text: String = ""
    /// Shows if the tweet is favourited or not
    var favorited: String = ""
    /// Shows the language of the tweet
    var lang: String = ""
    
    /// Shows the date that the tweet has been created
    var createdAt: Date? = nil

    /// Shows the user's info
    var user: TwitterDataTweetsUsersSocialFeedObject = TwitterDataTweetsUsersSocialFeedObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
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
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
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
