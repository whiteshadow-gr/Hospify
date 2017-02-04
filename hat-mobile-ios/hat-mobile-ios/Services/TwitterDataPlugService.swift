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

class TwitterDataPlugService: NSObject {
    
    class func twitterDataPlug(authToken: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> Void{
                
        HatAccountService.checkHatTableExists(tableName: "tweets",
            sourceName: "twitter",
            authToken: authToken,
            successCallback: getTweets(token: authToken, parameters: parameters, success: success),
            errorCallback: {() -> Void in return})
    }
    
    private class func getTweets(token: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void  {
        
        return {(tableID: NSNumber) -> Void in
            
            HatAccountService.getHatTableValues(token: token, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: {() -> Void in return})
        }
    }
    
    class func getAppTokenForTwitter(successful: @escaping (String) -> Void, failed: @escaping (Void) -> Void) {
        
        DataPlugsService.getApplicationTokenFor(serviceName: "Twitter", resource: "https://twitter-plug.hubofallthings.com", succesfulCallBack: successful, failCallBack: failed)
    }
    
    class func isTwitterDataPlugActive(token: String, successful: @escaping (Void) -> Void, failed: @escaping (Void) -> Void) {
        
        let url = "https://twitter-plug.hubofallthings.com/api/status"
        let parameters: Dictionary<String, String> = [:]
        let headers = ["X-Auth-Token" : token]
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: {(r : NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            case .isSuccess(_, let statusCode, _):
                
                if statusCode == 200 {
                    
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
    
    class func removeDuplicatesFrom(array: [JSON]) -> [TwitterSocialFeedObject] {
        
        var arrayToReturn: [TwitterSocialFeedObject] = []
        
        for dictionary in array {
            
            let object = TwitterSocialFeedObject(from: dictionary.dictionaryValue)
            
            let result = arrayToReturn.contains(where: {(tweet: TwitterSocialFeedObject) -> Bool in
                
                if object.data.tweets.id == tweet.data.tweets.id {
                    
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
    
    class func removeDuplicatesFrom(array: [TwitterSocialFeedObject]) -> [TwitterSocialFeedObject] {
        
        var arrayToReturn: [TwitterSocialFeedObject] = []
        
        for tweet in array {
            
            let result = arrayToReturn.contains(where: {(tweeter: TwitterSocialFeedObject) -> Bool in
                
                if tweet.data.tweets.id == tweeter.data.tweets.id {
                    
                    return true
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(tweet)
            }
        }
        
        return arrayToReturn
    }
}
