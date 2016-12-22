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

import SwiftyJSON

// MARK: Struct

/// A struct representing the author table received from JSON
struct AuthorData {
    
    // MARK: - Variables
    
    /// the nickname of the author
    var nickName: String
    /// the name of the author
    var name: String
    /// the photo url of the author
    var photoURL: String
    /// the id of the author
    var id: Int
    /// the phata of the author. Required
    var phata: String
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        nickName = ""
        name = ""
        photoURL = ""
        id = 0
        phata = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {
        
        // init optional JSON fields to default values
        self.init()
        
        // this field will always have a value no need to use if let
        if let tempPHATA = dict["phata"]?.string {
            
            phata = tempPHATA
        }

        // check optional fields for value, if found assign it to the correct variable
        if let tempID = dict["id"]?.stringValue {
            
            // check if string is "" as well
            if tempID != ""{
                
                if let intTempID = Int(tempID) {
                    
                    id = intTempID
                }
            }
        }
        
        if let tempNickName = dict["nick"]?.string {
            
            nickName = tempNickName
        }
        
        if let tempName = dict["name"]?.string {
            
            name = tempName
        }
        
        if let tempPhotoURL = dict["photo_url"]?.string {
            
            photoURL = tempPhotoURL
        }
    }
}
