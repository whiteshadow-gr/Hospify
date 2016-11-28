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
    
    /**
     Gets the notes of the user from the HAT
     
     - parameter token: The user's token
     - parameter tableID: The table id of the notes
     */
    class func getNotes(token: String, tableID: String) {
    
        // get user's hat domain
        let userDomain = self.TheUserHATDomain()
        
        // form the url
        let url = "https://"+userDomain+"/data/table/"+tableID+"/values?pretty=true"
            
        // create parameters and headers
        let parameters = ["starttime": "0"]
        let headers = ["X-Auth-Token": token]
        
        // make the request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: self.completionGetNotesFunction(token: token))
    }
    
    /**
     The completion method of the get notes function
     
     - parameter token: The user's token as a string
     - returns: (_ r: Helper.ResultType) -> Void
     */
    class func completionGetNotesFunction(token: String) -> (_ r: Helper.ResultType) -> Void {
        
        // post a notification if success with the array containing the notes
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
    
    /**
     Deletes a note from the hat
     
     - parameter id: the id of the note to delete
     - parameter tkn: the user's token as a string
     */
    class func deleteNoteWithKeychain(id: Int, tkn: String) -> Void {
        
        // get user's domain
        let userDomain = self.TheUserHATDomain()
        
        // form the url
        let url = "https://"+userDomain+"/data/record/"+String(id)
        
        // create parameters and headers
        let parameters = ["": ""]
        let headers = ["X-Auth-Token": tkn]
        
        // make the request
        NetworkHelper.AsynchronousRequest(url, method: .delete, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: self.completionDeleteNotesFunction(token: tkn))
    }
    
    /**
     Delete notes completion function
     
     - parameter token: The user's token as a string
     - returns: (_ r: Helper.ResultType) -> Void
     */
    class func completionDeleteNotesFunction(token: String) -> (_ r: Helper.ResultType) -> Void {
        
        return { (r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _):
                
                break
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    print(result)
                }
            }
        }
    }
}
