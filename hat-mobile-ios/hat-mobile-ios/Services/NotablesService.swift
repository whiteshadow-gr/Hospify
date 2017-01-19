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

import Alamofire
import SwiftyJSON
import Crashlytics

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
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    class func postNote(token: String, note: NotesData, successCallBack: @escaping () -> Void) -> Void {
        
        let userToken = HatAccountService.getUsersTokenFromKeychain()
        
        func posting(resultJSON: Dictionary<String, Any>) {
            
            // create JSON file for posting with default values
            let hatDataStructure = JSONHelper.createJSONForPostingOnNotables(hatTableStructure: resultJSON)
            // update JSON file with the values needed
            let hatData = JSONHelper.updateJSONFile(file: hatDataStructure, noteFile: note)
            
            // create the headers
            let headers = NetworkHelper.ConstructRequestHeaders(userToken)
            
            let domain = HatAccountService.TheUserHATDomain()
            
            // make async request
            NetworkHelper.AsynchronousRequest("https://" + domain + "/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: hatData, headers: headers, completion: { (r: Helper.ResultType) -> Void in
                
                // handle result
                switch r {
                    
                case .isSuccess(let isSuccess, _, _):
                    
                    if isSuccess {
                        
                        // reload table
                        successCallBack()
                    }
                    
                case .error(let error, let statusCode):
                    
                    print("error res: \(error)")
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "status code: " : "\(statusCode)"])
                }
            })
        }
        
        func errorCall() {
            
            
        }
        
        HatAccountService.checkHatTableExistsForUploading(tableName: "notablesv1", sourceName: "rumpel", authToken: userToken, successCallback: posting, errorCallback: errorCall)
    }
}
