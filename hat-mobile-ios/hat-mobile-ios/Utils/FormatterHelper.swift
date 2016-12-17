/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
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
    static func formatStringToDate(string: String) -> Date {
        
        // check if the string to format is empty
        if string == "" {
            
            // TODO: Return other date when string is empty
            return Date()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: string)
        
        // if date is nil try a different format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: string)
        }
        
        if date == nil {
            
            return Date()
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
