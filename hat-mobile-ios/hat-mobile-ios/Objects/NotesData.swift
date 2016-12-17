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

/// A struct representing the outer notes JSON format
struct NotesData {
    
    // MARK: - Variables
    
    /// the note id
    var id: Int
    /// the name of the note
    var name: String
    /// the last updated date of the note
    var lastUpdated: Date
    /// the data of the note, such as tables about the author, location, photo etc
    var data: NotablesData
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        id = 0
        name = ""
        lastUpdated = Date()
        data = NotablesData.init()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {

        id = 0
        name = ""
        lastUpdated = Date()
        data = NotablesData.init()
        
        if let tempID = dict["id"]?.int {
            
            id = tempID
        }
        if let tempName = dict["name"]?.string {
            
            name = tempName
        }
        if let tempLastUpdated = dict["lastUpdated"]?.string {
            
            lastUpdated = FormatterHelper.formatStringToDate(string: tempLastUpdated)
        }
        if let tempData = dict["data"]?["notablesv1"].dictionary {
            
            data = NotablesData.init(dict: tempData)
        }
    }
}
