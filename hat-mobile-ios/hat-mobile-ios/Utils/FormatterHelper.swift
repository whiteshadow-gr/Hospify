//
//  FormatterHelper.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 18/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

class FormatterHelper: NSObject {
    
    class func formatDateToISO(date: NSDate) -> String {
        
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale as Locale!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    class func formatStringToDate(string: String) -> Date {
        
        if string == "" {
            
            // TODO: Return other date when sting is empty
            return Date()
        }
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale as Locale!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: string)
        if date == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: string)
        }
        return date!
    }
    
    class func formatDateStringToUsersDefinedDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        var test = dateFormatter.string(from: date)
        test = test.replacingOccurrences(of: ",", with: " -")
        return test
    }
}
