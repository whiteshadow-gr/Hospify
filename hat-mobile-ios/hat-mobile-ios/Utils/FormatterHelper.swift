//
//  FormatterHelper.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 18/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

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
        
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    /**
     Formats a string into a Date
     
     - parameter string: The string to format to a Date
     - returns: Date
     */
    static func formatStringToDate(string: String) -> Date {
        
        // check if the string to format is empty
        if string == "" {
            
            // TODO: Return other date when string is empty
            return Date()
        }
        
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: string)
        
        // if date is nil try a different format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: string)
        }
        
        return date!
    }
    
    /**
     Formats a date to the user's defined date as a string
     
     - parameter date: The date to localize
     - returns: String
     */
    static func formatDateStringToUsersDefinedDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: date)
        
        return dateString.replacingOccurrences(of: ",", with: " -")
    }
}
