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

// MARK: Struct

/// A struct representing the location table received from JSON
public class HATNotesPhotoData: Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: HATNotesPhotoData, rhs: HATNotesPhotoData) -> Bool {
        
        return (lhs.link == rhs.link && lhs.source == rhs.source && lhs.caption == rhs.caption && lhs.shared == rhs.shared)
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
    public static func <(lhs: HATNotesPhotoData, rhs: HATNotesPhotoData) -> Bool {
        
        return lhs.source < rhs.source
    }
    
    // MARK: - Variables

    /// the link to the photo
    public var link: String
    /// the source of the photo
    public var source: String
    /// the caption of the photo
    public var caption: String
    
    /// if photo is shared
    public var shared: Bool
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        link = ""
        source = ""
        caption = ""
        shared = false
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public convenience init(dict: Dictionary<String, String>) {
        
        self.init()
        
        // check if shared exists and if is empty
        if let tempShared = dict["shared"] {
            
            if tempShared != "" {
                
                shared = true
            }
        }
        
        if let tempLink = dict["link"] {
            
            link = tempLink
        }
        
        if let tempSource = dict["source"] {
            
            source = tempSource
        }
        
        if let tempCaption = dict["caption"] {
            
            caption = tempCaption
        }
    }
}
