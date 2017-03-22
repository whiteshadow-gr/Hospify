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

/// A struct representing the outer notes JSON format
class HATNotesData: Comparable {
    
    // MARK: - Comparable protocol
    
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
    public static func <(lhs: HATNotesData, rhs: HATNotesData) -> Bool {
        
        return lhs.data.updatedTime < rhs.data.updatedTime
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: HATNotesData, rhs: HATNotesData) -> Bool {
        
        return lhs.data == lhs.data
    }

    // MARK: - Variables
    
    /// the note id
    var id: Int
    
    /// the name of the note
    var name: String
    
    /// the last updated date of the note
    var lastUpdated: Date
    
    /// the data of the note, such as tables about the author, location, photo etc
    var data: HATNotesNotablesData
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        id = 0
        name = ""
        lastUpdated = Date()
        data = HATNotesNotablesData.init()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    convenience init(dict: Dictionary<String, JSON>) {

        self.init()
        
        if let tempID = dict["id"]?.int {
            
            id = tempID
        }
        if let tempName = dict["name"]?.string {
            
            name = tempName
        }
        if let tempLastUpdated = dict["lastUpdated"]?.string {
            
            lastUpdated = HATFormatterHelper.formatStringToDate(string: tempLastUpdated)!
        }
        if let tempData = dict["data"]?["notablesv1"].dictionary {
            
            data = HATNotesNotablesData.init(dict: tempData)
        }
    }
}
