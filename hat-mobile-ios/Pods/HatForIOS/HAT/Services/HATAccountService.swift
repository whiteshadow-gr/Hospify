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
    public class func getHatTableValues(token: String, userDomain: String, tableID: NSNumber, parameters: Dictionary<String, String>, successCallback: @escaping ([JSON]) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
                
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
                case .isSuccess(let isSuccess, _, let result):
                    
                    if isSuccess {
                        
                        guard let array = result.array else {
                            
                            errorCallback(.noValuesFound)
                            return
                        }
                        
                        successCallback(array)
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
    public class func checkHatTableExists(userDomain: String, tableName: String, sourceName: String, authToken: String, successCallback: @escaping (NSNumber) -> Void, errorCallback: @escaping (HATTableError) -> Void) -> Void {
        
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
                case .isSuccess(let isSuccess, let statusCode, let result):
                    
                    if isSuccess {
                        
                        let tableID = result["fields"][0]["tableId"].number
                        
                        //table found
                        if statusCode == 200 {
                            
                            // get notes
                            if tableID != nil {
                                
                                successCallback(tableID!)
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
                    
                case .isSuccess(let isSuccess, let statusCode, _):
                    
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
                
            case .isSuccess(let isSuccess, let statusCode, _):
                
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
    public class func checkHatTableExistsForUploading(userDomain: String, tableName: String, sourceName: String, authToken: String, successCallback: @escaping (Dictionary<String, Any>) -> Void, errorCallback: @escaping (HATTableError) -> Void) -> Void {
        
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
                case .isSuccess(let isSuccess, let statusCode, let result):
                    
                    if isSuccess {
                        
                        //table found
                        if statusCode == 200 {
                            
                            guard let dictionary = result.dictionary else {
                                
                                break
                            }
                            successCallback(dictionary)
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
    public class func uploadFileToHAT(fileName: String, token: String, userDomain: String, completion: @escaping (FileUploadObject) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
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
                case .isSuccess(let isSuccess, let statusCode, let result):
                    
                    if isSuccess {
                        
                        let fileUploadJSON = FileUploadObject(from: result.dictionaryValue)
                        
                        //table found
                        if statusCode == 200 {
                            
                            completion(fileUploadJSON)
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
    public class func completeUploadFileToHAT(fileID: String, token: String, userDomain: String, completion: @escaping (FileUploadObject) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
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
                case .isSuccess(let isSuccess, let statusCode, let result):
                    
                    if isSuccess {
                        
                        let fileUploadJSON = FileUploadObject(from: result.dictionaryValue)
                        
                        //table found
                        if statusCode == 200 {
                            
                            completion(fileUploadJSON)
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
}
