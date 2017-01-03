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

// MARK: Struct

/// A struct representing the location table received from JSON
struct PhotoData {
    
    // MARK: - Variables

    /// the link to the photo
    var link: String
    /// the source of the photo
    var source: String
    /// the caption of the photo
    var caption: String
    
    /// if photo is shared
    var shared: Bool
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        link = ""
        source = ""
        caption = ""
        shared = false
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, String>) {
        
        self.init()
        
        // check if shared exists and if is empty
        if let tempShared = dict["shared"] {
            
            if tempShared != "" {
                
                shared = true
            }
        }
        
        if let tempLink = dict["link"] {
            
            link = tempLink
        }
        
        if let tempSource = dict["source"] {
            
            source = tempSource
        }
        
        if let tempCaption = dict["caption"] {
            
            caption = tempCaption
        }
    }
}
