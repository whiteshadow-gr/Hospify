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

// MARK : Class

public struct FileUploadObject: Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: FileUploadObject, rhs: FileUploadObject) -> Bool {
        
        return (lhs.dateCreated == rhs.dateCreated)
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
    public static func <(lhs: FileUploadObject, rhs: FileUploadObject) -> Bool {
        
        if lhs.lastUpdated != nil && rhs.lastUpdated != nil {
            
            return lhs.lastUpdated! < rhs.lastUpdated!
        }
        
        return false
    }

    // MARK: - Variables
    
    public var fileID: String = ""
    public var name: String = ""
    public var source: String = ""
    public var tags: [String] = []
    public var title: String = ""
    public var fileDescription: String = ""
    public var dateCreated: Date? = nil
    public var lastUpdated: Date? = nil
    public var status: FileUploadObjectStatus = FileUploadObjectStatus()
    public var contentURL: String = ""
    public var contentPublic: Bool = false
    public var permisions: [FileUploadObjectPermissions] = []
    
    // MARK : - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        fileID = ""
        name = ""
        source = ""
        tags = []
        title = ""
        fileDescription = ""
        dateCreated = nil
        lastUpdated = nil
        status = FileUploadObjectStatus()
        contentURL = ""
        contentPublic = false
        permisions = []
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: Dictionary<String, JSON>) {
        
        if let tempFileID = dict["fileId"]?.stringValue {
            
            fileID = tempFileID
        }
        if let tempName = dict["name"]?.stringValue {
            
            name = tempName
        }
        if let tempSource = dict["source"]?.stringValue {
            
            source = tempSource
        }
        if let tempTags = dict["tags"]?.arrayValue {
            
            for tag in tempTags {
                
                tags.append(tag.stringValue)
            }
        }
        if let tempTitle = dict["title"]?.stringValue {
            
            title = tempTitle
        }
        if let tempFileDescription = dict["description"]?.stringValue {
            
            fileDescription = tempFileDescription
        }
        if let tempDateCreated = dict["dateCreated"]?.intValue {
            
            dateCreated = HATFormatterHelper.formatStringToDate(string: String(tempDateCreated))
        }
        if let tempLastUpdate = dict["lastUpdated"]?.intValue {
            
            lastUpdated = HATFormatterHelper.formatStringToDate(string: String(tempLastUpdate))
        }
        if let tempContentURL = dict["contentUrl"]?.stringValue {
            
            contentURL = tempContentURL
        }
        if let tempContentPublic = dict["contentPublic"]?.boolValue {
            
            contentPublic = tempContentPublic
        }
        if let tempStatus = dict["status"]?.dictionary {
            
            status = FileUploadObjectStatus(from: tempStatus)
        }
        if let tempPermissions = dict["permissions"]?.arrayValue {
            
            for item in tempPermissions {
                
                permisions.append(FileUploadObjectPermissions(from: item.dictionaryValue))
            }
        }
    }
    
}
