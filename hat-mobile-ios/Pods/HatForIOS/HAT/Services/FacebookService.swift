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

public class FacebookService: NSObject {
    
    /**
     Fetches the facebook profile image of the user
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    class func fetchProfileFacebookPhoto(authToken: String, userDomain: String, parameters: Dictionary<String, String>,success: @escaping (_ array: [JSON]) -> Void) -> Void {
        
        HATAccountService.checkHatTableExists(userDomain: userDomain,
                                              tableName: "profile_picture",
                                              sourceName: "facebook",
                                              authToken: authToken,
                                              successCallback: getPosts(token: authToken, userDomain: userDomain, parameters: parameters, success: success),
                                              errorCallback: {(error: HATTableError) -> Void in return})
    }
    
    // MARK: - Facebook data plug
    
    /**
     Fetched the user's posts from facebook
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    class func facebookDataPlug(authToken: String, userDomain: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> Void {
        
        HATAccountService.checkHatTableExists(userDomain: userDomain,
                                              tableName: Facebook.tableName,
                                              sourceName: Facebook.sourceName,
                                              authToken: authToken,
                                              successCallback: getPosts(token: authToken, userDomain: userDomain, parameters: parameters, success: success),
                                              errorCallback: {(error: HATTableError) -> Void in return})
    }
    
    /**
     Checks if facebook plug is active
     
     - parameter token: The authorisation token to authenticate with the hat
     - parameter successful: An @escaping (Void) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    class func isFacebookDataPlugActive(token: String, successful: @escaping (Bool) -> Void, failed: @escaping (FacebookError) -> Void) {
        
        // construct the url, set parameters and headers for the request
        let url = Facebook.statusURL
        let parameters: Dictionary<String, String> = [:]
        let headers = [RequestHeaders.xAuthToken : token]
        
        // make the request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion: {(r : NetworkHelper.ResultType) -> Void in
            
            // act upon response
            switch r {
                
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess && result["canPost"].boolValue == true {
                    
                    successful(true)
                } else {
                    
                    successful(false)
                }
                
            // inform user that there was an error
            case .error(let error, let statusCode):
                
                let message = NSLocalizedString("Server responded with error", comment: "")
                failed(.generalError(message, statusCode, error))
            }
        })
    }
    
    // MARK: - Get posts
    
    /**
     Gets the facebook posts from database
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    private class func getPosts(token: String, userDomain: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void  {
        
        return {(tableID: NSNumber) -> Void in
            
            HATAccountService.getHatTableValues(token: token, userDomain: userDomain, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: {(error: HATTableError) -> Void in return})
        }
    }
    
    // MARK: - Get app token
    
    /**
     Gets application token for facebook
     
     - parameter successful: An @escaping (String) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    class func getAppTokenForFacebook(token: String, userDomain: String, successful: @escaping (String) -> Void, failed: @escaping (JSONParsingError) -> Void) {
        
        HATService.getApplicationTokenFor(serviceName: Facebook.serviceName, userDomain: userDomain, token: token, resource: Facebook.dataPlugURL, succesfulCallBack: successful, failCallBack: failed)
    }
    
    // MARK: - Remove duplicates
    
    /**
     Removes duplicates from a json file and returns the corresponding objects
     
     - parameter array: The JSON array
     - returns: An array of FacebookSocialFeedObject
     */
    class func removeDuplicatesFrom(array: [JSON]) -> [FacebookSocialFeedObject] {
        
        // the array to return
        var arrayToReturn: [FacebookSocialFeedObject] = []
        
        // go through each dictionary object in the array
        for dictionary in array {
            
            // transform it to an FacebookSocialFeedObject
            let object = FacebookSocialFeedObject(from: dictionary.dictionaryValue)
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(post: FacebookSocialFeedObject) -> Bool in
                
                if object.data.posts.id == post.data.posts.id {
                    
                    return true
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(object)
            }
        }
        
        return arrayToReturn
    }
    
    /**
     Removes duplicates from an array of FacebookSocialFeedObject and returns the corresponding objects in an array
     
     - parameter array: The FacebookSocialFeedObject array
     - returns: An array of FacebookSocialFeedObject
     */
    class func removeDuplicatesFrom(array: [FacebookSocialFeedObject]) -> [FacebookSocialFeedObject] {
        
        // the array to return
        var arrayToReturn: [FacebookSocialFeedObject] = []
        
        // go through each post object in the array
        for facebookPost in array {
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(post: FacebookSocialFeedObject) -> Bool in
                
                if facebookPost.data.posts.id == post.data.posts.id {
                    
                    return true
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(facebookPost)
            }
        }
        
        return arrayToReturn
    }
}
