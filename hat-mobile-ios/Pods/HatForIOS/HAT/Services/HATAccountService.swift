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

import SwiftyJSON
import Alamofire

// MARK: Class

/// A class about the methods concerning the user's HAT account
public class HATAccountService: NSObject {
    
    // MARK: - Get hat values from a table
    
    /**
     Gets values from a particular table
     
     - parameter token: The token in String format
     - parameter tableID: The table id as NSNumber
     - parameter parameters: The parameters to pass to the request, e.g. startime, endtime, limit
     - parameter successCallback: A callback called when successful of type @escaping ([JSON]) -> Void
     - parameter errorCallback: A callback called when failed of type @escaping (Void) -> Void)
     */
    public class func getHatTableValues(token: String, userDomain: String, tableID: NSNumber, parameters: Dictionary<String, String>, successCallback: @escaping ([JSON], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
                
        // form the url
        let url = "https://" + userDomain + "/data/table/" + tableID.stringValue + "/values?pretty=true"
        
        // create parameters and headers
        let headers = [RequestHeaders.xAuthToken : token]
        
        // make the request
        HATNetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion:
            { (r: HATNetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    errorCallback(.generalError(message, statusCode, error))
                case .isSuccess(let isSuccess, _, let result, let token):
                    
                    if isSuccess {
                        
                        guard let array = result.array else {
                            
                            errorCallback(.noValuesFound)
                            return
                        }
                        
                        successCallback(array, token)
                    }
                }
        })
    }
    
    /**
     Gets values from a particular table
    
    - parameter token: The token in String format
    - parameter tableID: The table id as NSNumber
    - parameter parameters: The parameters to pass to the request, e.g. startime, endtime, limit
    - parameter successCallback: A callback called when successful of type @escaping ([JSON]) -> Void
    - parameter errorCallback: A callback called when failed of type @escaping (Void) -> Void)
    */
    public class func getHatTableValuesWithOutPretty(token: String, userDomain: String, tableID: NSNumber, parameters: Dictionary<String, String>, successCallback: @escaping ([JSON], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // form the url
        let url = "https://" + userDomain + "/data/table/" + tableID.stringValue + "/values"
        
        // create parameters and headers
        let headers = [RequestHeaders.xAuthToken : token]
        
        // make the request
        HATNetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion:
            { (r: HATNetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    errorCallback(.generalError(message, statusCode, error))
                case .isSuccess(let isSuccess, _, let result, let token):
                    
                    if isSuccess {
                        
                        guard let array = result.array else {
                            
                            errorCallback(.noValuesFound)
                            return
                        }
                        
                        successCallback(array, token)
                    }
                }
        })
    }
    
    /**
     Checks if a table exists
     
     - parameter tableName: The table we are looking as String
     - parameter sourceName: The source name as String
     - parameter authToken: The user's token as String
     - parameter successCallback: A callback called when successful of type @escaping (NSNumber) -> Void
     - parameter errorCallback: A callback called when failed of type @escaping (Void) -> Void)
     */
    public class func checkHatTableExists(userDomain: String, tableName: String, sourceName: String, authToken: String, successCallback: @escaping (NSNumber, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) -> Void {
        
        // create the url
        let tableURL = "https://" + userDomain + "/data/table?name=" + tableName + "&source=" + sourceName
        
        // create parameters and headers
        let parameters: Dictionary<String, String> = [:]
        let header = [RequestHeaders.xAuthToken : authToken]
        
        // make async request
        HATNetworkHelper.AsynchronousRequest(
            tableURL,
            method: HTTPMethod.get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: parameters,
            headers: header,
            completion: {(r: HATNetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                case .error(let error, let statusCode):
                    
                    if statusCode == 404 {
                        
                        errorCallback(.tableDoesNotExist)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        errorCallback(.generalError(message, statusCode, error))
                    }
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess {
                        
                        let tableID = result["fields"][0]["tableId"].number
                        
                        //table found
                        if statusCode == 200 {
                            
                            // get notes
                            if tableID != nil {
                                
                                successCallback(tableID!, token)
                            } else {
                                
                                errorCallback(.noTableIDFound)
                            }
                        //table not found
                        } else if statusCode == 404 {
                            
                            errorCallback(.tableDoesNotExist)
                        } else {
                            
                            let message = NSLocalizedString("Server responded with error", comment: "")
                            errorCallback(.generalError(message, statusCode, nil))
                        }
                    }
                }
        })
    }
    
    // MARK: - Create table in hat
    
    /**
     Creates the notables table on the hat
     
     - parameter token: The token returned from the hat
     */
    public class func createHatTable(userDomain: String, token: String, notablesTableStructure: Dictionary<String, Any>, failed: @escaping (HATTableError) -> Void) -> (_ callback: Void) -> Void {
        
        return { (_ callback: Void) -> Void in
            
            // create headers and parameters
            let headers = ["Accept": ContentType.JSON,
                           "Content-Type": ContentType.JSON,
                           "X-Auth-Token": token]
            let url = "https://" + userDomain + "/data/table"
            
            // make async request
            HATNetworkHelper.AsynchronousRequest(url, method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: notablesTableStructure, headers: headers, completion: { (r: HATNetworkHelper.ResultType) -> Void in
                
                // handle result
                switch r {
                    
                case .isSuccess(let isSuccess, let statusCode, _, _):
                    
                    if isSuccess {
                        
                        callback
                        // if user is creating notables table send a notif back that the table has been created
                        NotificationCenter.default.post(name: NSNotification.Name("refreshTable"), object: nil)
                    } else {
                        
                        let message = NSLocalizedString("The request was not succesful", comment: "")
                        failed(.generalError(message, statusCode, nil))
                    }
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    failed(.generalError(message, statusCode, error))
                }
            })
        }
    }
    
    // MARK: - Delete from hat
    
    /**
     Deletes a record from hat
     
     - parameter token: The user's token
     - parameter recordId: The record id to delete
     - parameter success: A callback called when successful of type @escaping (String) -> Void
     */
    public class func deleteHatRecord(userDomain: String, token: String, recordId: Int, success: @escaping (String) -> Void, failed: @ escaping (HATTableError) -> Void) {
        
        // form the url
        let url = "https://" + userDomain+"/data/record/" + String(recordId)
        
        // create parameters and headers
        let parameters: Dictionary<String, String> = [:]
        let headers = [RequestHeaders.xAuthToken: token]
        
        // make the request
        HATNetworkHelper.AsynchronousRequest(url, method: .delete, encoding: Alamofire.URLEncoding.default, contentType: ContentType.Text, parameters: parameters, headers: headers, completion: { (r: HATNetworkHelper.ResultType) -> Void in

            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, let statusCode, _, _):
                
                if isSuccess {
                    
                    success(token)
                    HATAccountService.triggerHatUpdate(userDomain: userDomain, completion: {() -> Void in return})
                } else {
                    
                    let message = NSLocalizedString("The request was unsuccesful", comment: "")
                    failed(.generalError(message, statusCode, nil))
                }
                
            case .error(let error, let statusCode):
                
                let message = NSLocalizedString("Server responded with error", comment: "")
                failed(.generalError(message, statusCode, error))
            }
        })
    }
    
    // MARK: - Trigger an update
    
    /**
     Triggers an update to hat servers
     */
    public class func triggerHatUpdate(userDomain: String, completion: @escaping (Void) -> Void) -> Void {
        
        // define the url to connect to
        let url = "https://notables.hubofallthings.com/api/bulletin/tickle?"
        
        // make the request
        Alamofire.request(url, method: .get, parameters: ["phata": userDomain], encoding: Alamofire.URLEncoding.default, headers: nil).responseString { response in
            
            completion()
        }
    }
    
    /**
     Checks if a table exists
     
     - parameter tableName: The table we are looking as String
     - parameter sourceName: The source name as String
     - parameter authToken: The user's token as String
     - parameter successCallback: A callback called when successful of type @escaping (NSNumber) -> Void
     - parameter errorCallback: A callback called when failed of type @escaping (Void) -> Void)
     */
    public class func checkHatTableExistsForUploading(userDomain: String, tableName: String, sourceName: String, authToken: String, successCallback: @escaping (Dictionary<String, Any>, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) -> Void {
        
        // create the url
        let tableURL = "https://" + userDomain + "/data/table?name=" + tableName + "&source=" + sourceName
        
        // create parameters and headers
        let parameters: Dictionary<String, String> = [:]
        let header = [RequestHeaders.xAuthToken: authToken]
        
        // make async request
        HATNetworkHelper.AsynchronousRequest(
            tableURL,
            method: HTTPMethod.get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: parameters,
            headers: header,
            completion: {(r: HATNetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                case .error(let error, let statusCode):
                    
                    if statusCode == 404 {
                        
                        errorCallback(.tableDoesNotExist)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        errorCallback(.generalError(message, statusCode, error))
                    }
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess {
                        
                        //table found
                        if statusCode == 200 {
                            
                            guard let dictionary = result.dictionary else {
                                
                                break
                            }
                            
                            successCallback(dictionary, token)
                        //table not found
                        } else if statusCode == 404 {
                            
                            errorCallback(.tableDoesNotExist)
                        } else {
                            
                            let message = NSLocalizedString("Status code does not match expecations", comment: "")
                            errorCallback(.generalError(message, statusCode, nil))
                        }
                    } else {
                        
                        let message = NSLocalizedString("Respond is not succesful", comment: "")
                        errorCallback(.generalError(message, statusCode, nil))
                    }
                }
        })
    }
    
    // MARK: - Upload File to hat
    
    /**
     Uploads a file to hat
     
     - parameter fileName: The file name of the file to be uploaded
     - parameter token: The owner's token
     - parameter userDomain: The user hat domain
     - parameter completion: A function to execute on success, returning the object returned from the server
     - parameter errorCallback: A function to execute on failure, returning an error
     */
    public class func uploadFileToHAT(fileName: String, token: String, userDomain: String, completion: @escaping (FileUploadObject, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // create the url
        let uploadURL = "https://" + userDomain + "/api/v2/files/upload"
        
        // create parameters and headers
        let parameters: Dictionary<String, String> = HATJSONHelper.createFileUploadingJSONFrom(fileName: fileName) as! Dictionary<String, String>
        let header = ["X-Auth-Token" : token]
        
        // make async request
        HATNetworkHelper.AsynchronousRequest(
            uploadURL,
            method: HTTPMethod.post,
            encoding: Alamofire.JSONEncoding.default,
            contentType: "application/json",
            parameters: parameters,
            headers: header,
            completion: {(r: HATNetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    errorCallback(.generalError(message, statusCode, error))
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess {
                        
                        let fileUploadJSON = FileUploadObject(from: result.dictionaryValue)
                        
                        //table found
                        if statusCode == 200 {
                            
                            completion(fileUploadJSON, token)
                        } else {
                            
                            let message = NSLocalizedString("Server responded with error", comment: "")
                            errorCallback(.generalError(message, statusCode, nil))
                        }
                    }
                }
        })
    }
    
    /**
     Completes an upload of a file to hat
     
     - parameter fileID: The fileID of the file uploaded to hat
     - parameter token: The owner's token
     - parameter userDomain: The user hat domain
     - parameter completion: A function to execute on success, returning the object returned from the server
     - parameter errorCallback: A function to execute on failure, returning an error
     */
    public class func completeUploadFileToHAT(fileID: String, token: String, userDomain: String, completion: @escaping (FileUploadObject, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // create the url
        let uploadURL = "https://" + userDomain + "/api/v2/files/file/" + fileID + "/complete"
        
        // create parameters and headers
        let header = ["X-Auth-Token" : token]
        
        // make async request
        HATNetworkHelper.AsynchronousRequest(
            uploadURL,
            method: HTTPMethod.put,
            encoding: Alamofire.JSONEncoding.default,
            contentType: "application/json",
            parameters: [:],
            headers: header,
            completion: {(r: HATNetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    errorCallback(.generalError(message, statusCode, error))
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess {
                        
                        let fileUploadJSON = FileUploadObject(from: result.dictionaryValue)
                        
                        //table found
                        if statusCode == 200 {
                            
                            completion(fileUploadJSON, token)
                        } else {
                            
                            let message = NSLocalizedString("Server responded with error", comment: "")
                            errorCallback(.generalError(message, statusCode, nil))
                        }
                    }
                }
        })
    }
    
    /**
     Constructs URL to get the public key
     
     - parameter userHATDomain: The user's HAT domain
     
     - returns: HATRegistrationURLAlias
     */
    public class func TheUserHATDomainPublicKeyURL(_ userHATDomain: String) -> String? {
        
        if let escapedUserHATDomain: String = userHATDomain.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            let url: String = "https://" + escapedUserHATDomain + "/" + "publickey"
            
            return url
        }
        
        return nil
    }
    
    // MARK: - Profile
    
    /**
     Searches for profile table and fetches the entries
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public class func getProfileFromHAT(userDomain: String, userToken: String, successCallback: @escaping (HATProfileObject) -> Void, failCallback: @escaping (HATTableError) -> Void) -> Void {
        
        func tableFound (tableID: NSNumber, newToken: String?) {
            
            func profileEntries(json: [JSON], renewedToken: String?) {
                
                // if we have values return them
                if json.count > 0 {
                    
                    let array = HATProfileObject(from: json[0].dictionaryValue)
                    successCallback(array)
                // in case no values have found then that means that the users hasn't entered anything yet so we have to get the structure from the ccheckHatTableExistsForUploading method in order to have the id's
                } else {
                    
                    HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: {(dict) in
                    
                        let array = HATProfileObject(alternativeDictionary: dict.0 as! Dictionary<String, JSON>)
                        successCallback(array)
                    }, errorCallback: {(error) in
                    
                        failCallback(HATTableError.noValuesFound)
                    })
                }
            }
            
            HATAccountService.getHatTableValuesWithOutPretty(token: userToken, userDomain: userDomain, tableID: tableID, parameters: ["starttime" : "0"], successCallback: profileEntries, errorCallback: failCallback)
        }
        
        HATAccountService.checkHatTableExists(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: tableFound, errorCallback: failCallback)
    }
    
    // MARK: - Post note
    
    /**
     Posts the profile record to the hat
     
     - parameter userDomain: The user's Domain
     - parameter userToken: The user's token
     - parameter profile: The profile to be used to update the JSON send to the hat
     - parameter successCallBack: A Function to execute
     */
    public class func postProfile(userDomain: String, userToken: String, hatProfile: HATProfileObject, successCallBack: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) -> Void {
        
        func posting(resultJSON: Dictionary<String, Any>, token: String?) {
            
            // create the headers
            let headers = ["Accept": ContentType.JSON,
                           "Content-Type": ContentType.JSON,
                           "X-Auth-Token": userToken]
            
            // create JSON file for posting with default values
            let hatDataStructure = HATJSONHelper.createJSONForPosting(hatTableStructure: resultJSON)
            // update JSON file with the values needed
            let hatData = HATJSONHelper.updateProfileJSONFile(file: hatDataStructure, profileFile: hatProfile)
            
            // make async request
            HATNetworkHelper.AsynchronousRequest("https://" + userDomain + "/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: hatData, headers: headers, completion: { (r: HATNetworkHelper.ResultType) -> Void in
                
                // handle result
                switch r {
                    
                case .isSuccess(let isSuccess, _, _, _):
                    
                    if isSuccess {
                        
                        // reload table
                        successCallBack()
                        
                        HATAccountService.triggerHatUpdate(userDomain: userDomain, completion: {()})
                    }
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    errorCallback(.generalError(message, statusCode, error))
                }
            })
        }
        
        func errorCall(error: HATTableError) {
            
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: posting, errorCallback: errorCall)
    }
    
    // MARK: - Change Password
    
    /**
     Changes the user's password
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's authentication token
     - parameter oldPassword: The old password the user entered
     - parameter newPassword: The new password to change to
     - parameter successCallback: A function of type (String, String?) to call on success
     - parameter failCallback: A fuction of type (HATError) to call on fail
     */
    public class func changePassword(userDomain: String, userToken: String, oldPassword: String, newPassword: String, successCallback: @escaping (String, String?) -> Void, failCallback: @escaping (HATError) -> Void) -> Void {
        
        let url = "https://" + userDomain + "/control/v2/auth/password"
        
        let parameters: Dictionary = ["password" : oldPassword,
                                      "newPassword" : newPassword]
        let headers = [RequestHeaders.xAuthToken : userToken]
        
        HATNetworkHelper.AsynchronousRequest(url, method: .post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion: {(r: HATNetworkHelper.ResultType) -> Void in
            
            switch r {
                
            case .error(let error, let statusCode):
                
                let message = NSLocalizedString("Server responded with error", comment: "")
                failCallback(.generalError(message, statusCode, error))
            case .isSuccess(let isSuccess, _, let result, let token):
                
                if isSuccess {
                    
                    //table found
                    if let message = result.dictionaryValue["message"]?.stringValue {
                        
                        successCallback(message, token)
                    }
                }
            }
        })
    }
}
