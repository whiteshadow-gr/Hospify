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

class FacebookDataPlugService: NSObject {
    
    class func fetchProfileFacebookPhoto(authToken: String, parameters: Dictionary<String, String>,success: @escaping (_ array: [JSON]) -> Void) -> Void {
        
        HatAccountService.checkHatTableExists(tableName: "profile_picture",
                                              sourceName: "facebook",
                                              authToken: authToken,
                                              successCallback: getPosts(token: authToken, parameters: parameters, success: success),
                                              errorCallback: {() -> Void in return})
    }
    
    class func facebookDataPlug(authToken: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> Void {
        
        HatAccountService.checkHatTableExists(tableName: "posts",
                                              sourceName: "facebook",
                                              authToken: authToken,
                                              successCallback: getPosts(token: authToken, parameters: parameters, success: success),
                                              errorCallback: {() -> Void in return})
    }

    private class func getPosts(token: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void  {
        
        return {(tableID: NSNumber) -> Void in
            
            HatAccountService.getHatTableValues(token: token, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: {() -> Void in return})
        }
    }
    
    class func getAppTokenForFacebook(successful: @escaping (String) -> Void, failed: @escaping (Void) -> Void) {
        
        DataPlugsService.getApplicationTokenFor(serviceName: "Facebook", resource: "https://social-plug.hubofallthings.com", succesfulCallBack: successful, failCallBack: failed)
    }
    
    class func isFacebookDataPlugActive(token: String, successful: @escaping (Void) -> Void, failed: @escaping (Void) -> Void) {
        
        let url = "https://social-plug.hubofallthings.com/api/user/token/status"
        let parameters: Dictionary<String, String> = [:]
        let headers = ["X-Auth-Token" : token]
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: {(r : NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess && result["canPost"].boolValue == true {
                    
                    successful()
                } else {
                    
                    failed()
                }
                
            // inform user that there was an error
            case .error(_, _):
                
                failed()
            }
        })
    }
    
    class func removeDuplicatesFrom(array: [JSON]) -> [FacebookSocialFeedObject] {
        
        var arrayToReturn: [FacebookSocialFeedObject] = []
        
        for dictionary in array {
            
            let object = FacebookSocialFeedObject(from: dictionary.dictionaryValue)
            
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
    
    class func removeDuplicatesFrom(array: [FacebookSocialFeedObject]) -> [FacebookSocialFeedObject] {
        
        var arrayToReturn: [FacebookSocialFeedObject] = []
        
        for facebookPost in array {
            
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
