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
            
            return hatDomain;
        }
        
        return ""
    }
    
    /**
     Creates the notables table on the hat
     
     - parameter token: The token returned from the hat
     */
    class func createNotablesTable(token: String) -> (_ callback: Void) -> Void {
        
        return { (_ callback: Void) -> Void in
            
            // create headers and parameters
            let parameters = JSONHelper.createNotablesTableJSON()
            let headers = Helper.ConstructRequestHeaders(token)
            
            // make async request
            NetworkHelper.AsynchronousRequest("https://tablestest.hubofallthings.net/data/table", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
                
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
     Gets user token from the hat
     
     - parameter completion: A function variable of type, @escaping (_ token: String) -> Void)
     */
    class func getUserToken(completion: @escaping (_ token: String) -> Void) -> Void {
        
        // get auth token
        let authTokenUrl = Helper.TheUsersAccessTokenURL()
        
        // create parameters and headers
        let parameters = ["": ""]
        let headers = ["username": "mariostsekis", "password": "K46-Gss-ECe-Rqr"]
        
        // create function variable to get the token
        let successfulTokenNextStep = self.getUserTokenCompletionFunction(callback: completion)
        
        // make async request
        NetworkHelper.AsynchronousRequest(authTokenUrl, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion:successfulTokenNextStep)
    }
    
    /**
     Gets user token completion function
     
     - parameter callback: A function variable of type, @escaping (String) -> Void) -> (_ r: Helper.ResultType)
     */
    private class func getUserTokenCompletionFunction (callback: @escaping (String) -> Void) -> (_ r: Helper.ResultType) -> Void {
        
        // return the token
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
    
    class func getNotes(token: String, tableID: String) {
    
        let userDomain = self.TheUserHATDomain()
        
        let url = "https://"+userDomain+"/data/table/"+tableID+"/values?pretty=true"
            
        // create parameters and headers
        let parameters = ["": ""]
        let headers = ["X-Auth-Token": token]
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: self.completionFunction(token: token))
    }
    
    class func completionFunction(token: String) -> (_ r: Helper.ResultType) -> Void {
        
        return { (r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _):
                
                break
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notesArray"), object: result.array!)
                }
            }
        }
    }
}
