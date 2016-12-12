//
//  HatAccountService.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 15/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire
import SwiftyJSON

class HatAccountService {
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: HATUsername
     */
    class func TheHATUsername() -> Constants.HATUsernameAlias {
        
        return Constants.HATDataPlugCredentials.HAT_Username
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: HATPassword
     */
    class func TheHATPassword() -> Constants.HATPasswordAlias {
        
        return Constants.HATDataPlugCredentials.HAT_Password
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: UserHATDomainAlias
     */
    class func TheUserHATDomain() -> Constants.UserHATDomainAlias {
        
        if let hatDomain = Helper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            return hatDomain
        }
        
        return ""
    }
    
    class func deleteHatRecord(token: String, recordId: Int, success: @escaping (String) -> Void) {
        // get user's domain
        let userDomain = HatAccountService.TheUserHATDomain()
        
        // form the url
        let url = "https://"+userDomain+"/data/record/"+String(recordId)
        
        // create parameters and headers
        let parameters = ["": ""]
        let headers = ["X-Auth-Token": token]
        
        // make the request
        NetworkHelper.AsynchronousRequest(url, method: .delete, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
            
            // handle result
            switch r {
            
            case .isSuccess(let isSuccess, _, _):
            
            if isSuccess {
            
            success(token)
            }
            
            case .error(let error, _):
            
            print("error res: \(error)")
            }
            })
    }
    
    /**
     Creates the notables table on the hat
     
     - parameter token: The token returned from the hat
     */
    class func createHatTable(token: String, notablesTableStructure: Dictionary<String, Any>) -> (_ callback: Void) -> Void {
        
        return { (_ callback: Void) -> Void in
            
            // create headers and parameters
            //let parameters = JSONHelper.createNotablesTableJSON()
            let headers = Helper.ConstructRequestHeaders(token)
            let url = HatAccountService.TheUserHATDomain() + "/data/table"
            
            // make async request
            NetworkHelper.AsynchronousRequest(url, method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: notablesTableStructure, headers: headers, completion: { (r: Helper.ResultType) -> Void in
                
                // handle result
                switch r {
                    
                case .isSuccess(let isSuccess, _, _):
                    
                    if isSuccess {
                        
                        callback
                    }
                    
                case .error(let error, _):
                    
                    print("error res: \(error)")
                }
            })
        }
    }
    
    /**
     Gets user's token from keychain
     
     - returns: The token as a string
     */
    class func getUsersTokenFromKeychain() -> String {
        
        // check if the token has been saved in the keychain and return it. Else return an empty string
        if let token = Helper.GetKeychainValue(key: "UserToken") {
            
            return token
        }
        
        return ""
    }
    
    /**
     Gets user token completion function
     
     - parameter callback: A function variable of type, @escaping (String) -> Void) -> (_ r: Helper.ResultType)
     */
    private class func getUserTokenCompletionFunction (callback: @escaping (String) -> Void) -> (_ r: Helper.ResultType) -> Void {
        
        // return the token if success
        return { (_ r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _):
                
                break
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    let checkResult: String = "accessToken"
                    
                    if result[checkResult].exists() {
                        
                        callback(result[checkResult].stringValue)
                        print(result[checkResult].stringValue)
                    }
                }
            }
        }
    }
    
    // MARK: - Network functions
    
    class func checkHatTableExists(tableName: String, sourceName: String, authToken: String, successCallback: @escaping (NSNumber) -> Void, errorCallback: @escaping (Void) -> Void) -> Void {
        
        // create the url
        let tableURL = Helper.TheUserHATCheckIfTableExistsURL(tableName: tableName, sourceName: sourceName)
        
        // create parameters and headers
        let parameters = ["": ""]
        let header = ["X-Auth-Token": authToken]
        
        // make async request
        NetworkHelper.AsynchronousRequest(
            tableURL,
            method: HTTPMethod.get,
            encoding: Alamofire.URLEncoding.default,
            contentType: Constants.ContentType.JSON,
            parameters: parameters,
            headers: header,
            completion: {(r: Helper.ResultType) -> Void in
                
                switch r {
                    
                case .error( _, _): break
                    
                case .isSuccess(let isSuccess, let statusCode, let result):
                    
                    if isSuccess {
                        
                        let tableID = result["fields"][0]["tableId"].number
                        
                        //table found
                        if statusCode == 200 {
                            
                            // get notes
                            if tableID != nil {
                                
                                successCallback(tableID!)
                            }
                            //table not found
                        } else if statusCode == 404 {
                            
                            errorCallback()
                        }
                    }
                }
        })
    }

    
    
    class func getHatTableValues(token: String, tableID: NSNumber, successCallback: @escaping ([JSON]) -> Void, errorCallback: @escaping (Void) -> Void) {
    
    // get user's hat domain
    let userDomain = self.TheUserHATDomain()
            
    // form the url
    let url = "https://"+userDomain+"/data/table/"+tableID.stringValue+"/values?pretty=true"
    
    // create parameters and headers
    let parameters = ["starttime": "0"]
    let headers = ["X-Auth-Token": token]
    
    // make the request
    NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers,
                                      completion: //completionGetNotesFunction
                                        { (r: Helper.ResultType) -> Void in
                                            
                                            switch r {
                                                
                                            case .error( _, _):
                                                
                                                break
                                            case .isSuccess(let isSuccess, _, let result):
                                                
                                                if isSuccess {
                                                    
                                                    if let array = result.array {
                                                        
                                                        successCallback(array)
                                                    } else {
                                                        
                                                        errorCallback()
                                                    }
                                                }
                                            }
    })
    }

    
    
}
