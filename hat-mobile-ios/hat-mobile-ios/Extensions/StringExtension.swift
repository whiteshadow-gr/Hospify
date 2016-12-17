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
