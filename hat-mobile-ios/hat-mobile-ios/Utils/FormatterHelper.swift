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

}
