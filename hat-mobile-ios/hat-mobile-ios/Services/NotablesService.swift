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
    class func fetchNotables(authToken: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void, failure: @escaping () -> Void ) -> Void {
        
        func createNotablesTables() {
            
            HatAccountService.createHatTable(token: authToken, notablesTableStructure: JSONHelper.createNotablesTableJSON())()
            
            failure()
        }
        
        HatAccountService.checkHatTableExists(tableName: "notablesv1", //posts // tweets
                            sourceName: "rumpel", // facebook // twitter
                            authToken: authToken,
                            successCallback: getNotes(token: authToken, parameters: parameters, success: success),
                            errorCallback: createNotablesTables)
    }
    
    /**
     Gets the notes of the user from the HAT
     
     - parameter token: The user's token
     - parameter tableID: The table id of the notes
     */
    private class func getNotes (token: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void {
        
        return { (tableID: NSNumber) -> Void in
        
            HatAccountService.getHatTableValues(token: token, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: showNotablesFetchError)
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
    
    // MARK: - Post note
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    class func postNote(token: String, note: NotesData, successCallBack: @escaping () -> Void, errorCallback: @escaping () -> Void) -> Void {
        
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
            NetworkHelper.AsynchronousRequest("https://" + domain + "/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: hatData, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
                
                // handle result
                switch r {
                    
                case .isSuccess(let isSuccess, let statusCode, _):
                    
                    if isSuccess {
                        
                        // reload table
                        successCallBack()
                        HatAccountService.triggerHatUpdate()
                    } else if statusCode == 401 {
                        
                        errorCallback()
                    }
                    
                case .error(let error, let statusCode):
                    
                    print("error res: \(error)")
                    errorCallback()
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "status code: " : "\(statusCode)"])
                }
            })
        }
        
        HatAccountService.checkHatTableExistsForUploading(tableName: "notablesv1", sourceName: "rumpel", authToken: userToken, successCallback: posting, errorCallback: errorCallback)
    }
    
    // MARK: - Remove duplicates
    
    /**
     Removes duplicates from an array of NotesData and returns the corresponding objects in an array
     
     - parameter array: The NotesData array
     - returns: An array of NotesData
     */
    class func removeDuplicatesFrom(array: [NotesData]) -> [NotesData] {
        
        // the array to return
        var arrayToReturn: [NotesData] = []
        
        // go through each tweet object in the array
        for note in array {
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(note2: NotesData) -> Bool in
                
                if (note.data.createdTime == note2.data.createdTime) && (note.data.message == note2.data.message) {
                    
                    return true
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(note)
            }
        }
        
        for (outterIndex, note) in arrayToReturn.enumerated().reversed() {
            
            for (innerIndex, innerNote) in arrayToReturn.enumerated().reversed() {
                
                if outterIndex != innerIndex {
                    
                    if innerNote.data.createdTime == note.data.createdTime {
                    
                        if innerNote.lastUpdated != note.lastUpdated {

                            if innerNote.lastUpdated > note.lastUpdated {
                                
                                arrayToReturn.remove(at: outterIndex)
                            } else {
                                
                                arrayToReturn.remove(at: innerIndex)
                            }
                        }
                    }
                }
            }
        }
        
        return NotablesService.sortNotables(notes: arrayToReturn)
    }
    
    // MARK: - Sort notables
    
    /**
     Sorts notes based on updated time
     
     - parameter notes: The NotesData array
     - returns: An array of NotesData
     */
    class func sortNotables(notes: [NotesData]) -> [NotesData] {
                
        return notes.sorted{ $0.data.updatedTime > $1.data.updatedTime }
    }
}
