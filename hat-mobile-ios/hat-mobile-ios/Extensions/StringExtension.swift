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

// MARK: String extension

extension String {
    
    // MARK: - Convert from base64URL to base64
    
    /**
     String extension to convert from base64Url to base64
     
     parameter s: The string to be converted
     
     returns: A Base64 String
     */
    public func fromBase64URLToBase64(s: String) -> String {
        
        var s = s
        if (s.characters.count % 4 == 2 ) {
            
            s = s + "=="
        } else if (s.characters.count % 4 == 3 ) {
            
            s = s + "="
        }
        
        s = s.replacingOccurrences(of: "-", with: "+")
        s = s.replacingOccurrences(of: "_", with: "/")
        
        return s
    }
    
    // MARK: - Split a comma separated string to an Array of String
    
    /**
     Transforms a comma seperated string into an array
     
     - returns: [String]
     */
    func stringToArray() -> [String] {
        
        let trimmedString = self.replacingOccurrences(of: " ", with: "")
        var array = trimmedString.components(separatedBy: ",")
        
        if array.last == "" {
            
            array.removeLast()
        }
        
        return array
    }
    
    /**
     Trims a given String
     
     - parameter string: the String to trim
     - returns: trimmed String
     */
    func TrimString() -> String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // MARK: - Text Attributes
    
    func createTextAttributes(foregroundColor: UIColor, strokeColor: UIColor, font: UIFont) -> NSAttributedString {
        
        let textAttributes = [
            NSForegroundColorAttributeName: foregroundColor,
            NSStrokeColorAttributeName: strokeColor,
            NSFontAttributeName: font,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        return NSAttributedString(string: self + "\n", attributes: textAttributes)
    }
}
