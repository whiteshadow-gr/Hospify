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

import Alamofire
import SwiftyJSON

// MARK: Class

/// A class about the methods concerning the Notables service
class NotablesService: NSObject {
    
    // MARK: - Get Notes
    
    /**
     Checks if notables table exists
     
     - parameter authToken: The auth token from hat
     */
    class func fetchNotables(authToken: String, success: @escaping (_ array: [JSON]) -> Void ) -> Void {
        
        let createNotablesTables = HatAccountService.createHatTable(token: authToken, notablesTableStructure: JSONHelper.createNotablesTableJSON())
        
        HatAccountService.checkHatTableExists(tableName: "notablesv1",
                            sourceName: "rumpel",
                            authToken: authToken,
                            successCallback: getNotes(token: authToken, success: success),
                            errorCallback: createNotablesTables)
    }
    
    /**
     Gets the notes of the user from the HAT
     
     - parameter token: The user's token
     - parameter tableID: The table id of the notes
     */
    private class func getNotes (token: String, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void {
        
        return { (tableID: NSNumber) -> Void in
        
            HatAccountService.getHatTableValues(token: token, tableID: tableID, successCallback: success, errorCallback: showNotablesFetchError)
        }
    }
    
    /**
     Shows alert that the notes couldn't be fetched
     */
    class func showNotablesFetchError() {
        
        // alert magic
    }
    
    // MARK: - Delete notes
    
    /**
     Deletes a note from the hat
     
     - parameter id: the id of the note to delete
     - parameter tkn: the user's token as a string
     */
    class func deleteNoteWithKeychain(id: Int, tkn: String) -> Void {
        
        HatAccountService.deleteHatRecord(token: tkn, recordId: id, success: self.completionDeleteNotesFunction)
    }
    
    /**
     Delete notes completion function
     
     - parameter token: The user's token as a string
     - returns: (_ r: Helper.ResultType) -> Void
     */
    class func completionDeleteNotesFunction(token: String) -> Void {
        
        print(token)
    }
}
