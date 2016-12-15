//
//  StringExtension.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 12/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

// MARK: String extension

extension String {
    
    // MARK: - Convert from base64URL to base64
    
    /**
     String extension to convert from base64Url to base64
     
     parameter s: The string to be converted
     
     returns: A Base64 String
     */
    func fromBase64URLToBase64(s: String) -> String {
        
        var s = s;
        if (s.characters.count % 4 == 2 ) {
            
            s = s + "=="
        }else if (s.characters.count % 4 == 3 ) {
            
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
}
