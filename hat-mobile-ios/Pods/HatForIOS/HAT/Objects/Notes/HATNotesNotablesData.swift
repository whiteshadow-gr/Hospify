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

/// A struct representing the notables table received from JSON
class HATNotesNotablesData: Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: HATNotesNotablesData, rhs: HATNotesNotablesData) -> Bool {
        
        return (lhs.authorData == rhs.authorData && lhs.photoData == rhs.photoData && lhs.locationData == rhs.locationData
            && lhs.createdTime == rhs.createdTime && lhs.publicUntil == rhs.publicUntil && lhs.updatedTime == rhs.updatedTime && lhs.shared == rhs.shared && lhs.sharedOn == rhs.sharedOn && lhs.message == rhs.message && lhs.kind == rhs.kind)
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
    public static func <(lhs: HATNotesNotablesData, rhs: HATNotesNotablesData) -> Bool {
        
        return lhs.updatedTime < rhs.updatedTime
    }

    
    // MARK: - Variables
    
    /// the author data
    var authorData: HATNotesAuthorData
    
    /// the photo data
    var photoData: HATNotesPhotoData
    
    /// the location data
    var locationData: HATNotesLocationData
    
    /// creation date
    var createdTime: Date
    /// the date until this note will be public (don't know if it's optional or not)
    var publicUntil: Date?
    /// the updated time of the note
    var updatedTime: Date
    
    /// if true this note is shared to facebook etc.
    var shared: Bool
    
    /// If shared, where is it shared? Coma seperated string (don't know if it's optional or not)
    var sharedOn: String
    /// the actual message of the note
    var message: String
    /// the kind of the note. 3 types available note, blog or list
    var kind: String
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        authorData = HATNotesAuthorData.init()
        createdTime = Date()
        shared = false
        sharedOn = ""
        photoData = HATNotesPhotoData.init()
        locationData = HATNotesLocationData.init()
        message = ""
        publicUntil = nil
        updatedTime = Date()
        kind = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(dict: Dictionary<String, JSON>) {

        // the tables are optional fields in the json so init them and check if they exist in our json
        self.init()
        
        if let tempAuthorData = dict["authorv1"]?.dictionary {
            
             authorData = HATNotesAuthorData.init(dict: tempAuthorData)
        }
        
        if let tempPhotoData = dict["photov1"]?.dictionaryObject {
            
            photoData = HATNotesPhotoData.init(dict: tempPhotoData as! Dictionary<String, String>)
        }
        
        if let tempLocationData = dict["locationv1"]?.dictionary {
            
            locationData = HATNotesLocationData.init(dict: tempLocationData)
        }
        
        if let tempSharedOn = dict["shared_on"]?.string {
            
            sharedOn = tempSharedOn
        }
        
        if let tempPublicUntil = dict["public_until"]?.string {
            
            publicUntil = HATFormatterHelper.formatStringToDate(string: tempPublicUntil)
        }
        
        if let tempCreatedTime = dict["created_time"]?.string {
            
            let returnedDate = HATFormatterHelper.formatStringToDate(string: tempCreatedTime)
            if returnedDate != nil {
                
                createdTime = returnedDate!
            }
        }

        if let tempDict = dict["shared"]?.string {
            
            if tempDict == "" {
                
                shared = false
            } else {
                
                if let boolShared = Bool(tempDict) {
                    
                    shared = boolShared
                }
            }
        }
        
        if let tempMessage = dict["message"]?.string {
            
            message = tempMessage
        }
        
        if let tempKind = dict["kind"]?.string {
            
            kind = tempKind
        }
    }
}
