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

import UIKit

// MARK: Struct

/// A struct for everything that formats something
struct FormatterHelper {
    
    // MARK: - Date formaters
    
    /**
     Formats a date to ISO 8601 format
     
     - parameter date: The date to format
     - returns: String
     */
    static func formatDateToISO(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return dateFormatter.string(from: date as Date)
    }
    
    /**
     Formats a string into a Date
     
     - parameter string: The string to format to a Date
     - returns: Date
     */
    static func formatStringToDate(string: String) -> Date? {
        
        // check if the string to format is empty
        if string == "" {
            
            // TODO: Return other date when string is empty
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: string)
        
        // if date is nil try a different format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: string)
        }
        
        // if date is nil try a different format, for twitter format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
            date = dateFormatter.date(from: string)
        }
        
        return date
    }
    
    /**
     Formats a date to the user's defined date as a string
     
     - parameter date: The date to localize
     - returns: String
     */
    static func formatDateStringToUsersDefinedDate(date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        let dateString = dateFormatter.string(from: date)
        
        return dateString.replacingOccurrences(of: ",", with: " -")
    }
    
    static func getDateFromString(_ dateString : String) -> Date! {
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.UTC
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: dateString)
        
        return date
    }
    
    static func getDateString(_ datetime : Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.full
        formatter.timeStyle = DateFormatter.Style.medium
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let date = formatter.string(from: datetime)
        
        return date
    }
    
    static func getDateString(_ datetime : Date, format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let date = formatter.string(from: datetime)
        
        return date
    }
}
