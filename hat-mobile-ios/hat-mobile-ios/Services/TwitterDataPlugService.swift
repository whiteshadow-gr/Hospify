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

// MARK: Class

/// The twitter data plug service class
class TwitterDataPlugService: NSObject {
    
    // MARK: - Twitter data plug
    
    /**
     Fetched the user's posts from twitter
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    class func twitterDataPlug(authToken: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> Void{
                
        AccountService.checkHatTableExists(tableName: "tweets",
            sourceName: "twitter",
            authToken: authToken,
            successCallback: getTweets(token: authToken, parameters: parameters, success: success),
            errorCallback: {(statusCode) -> Void in return})
    }
    
    /**
     Checks if twitter plug is active
     
     - parameter token: The authorisation token to authenticate with the hat
     - parameter successful: An @escaping (Void) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    class func isTwitterDataPlugActive(token: String, successful: @escaping (Void) -> Void, failed: @escaping (Void) -> Void) {
        
        // construct the url, set parameters and headers for the request
        let url = "https://twitter-plug.hubofallthings.com/api/status"
        let parameters: Dictionary<String, String> = [:]
        let headers = ["X-Auth-Token" : token]
        
        // make the request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: {(r : NetworkHelper.ResultType) -> Void in
            
            // act upon response
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
    
    // MARK: - Get tweets
    
    /**
     Gets tweets from database
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    private class func getTweets(token: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void  {
        
        return {(tableID: NSNumber) -> Void in
            
            AccountService.getHatTableValues(token: token, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: {() -> Void in return})
        }
    }
    
    // MARK: - Get application token for twitter
    
    /**
     Gets application token for twitter
     
     - parameter successful: An @escaping (String) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    class func getAppTokenForTwitter(successful: @escaping (String) -> Void, failed: @escaping (Void) -> Void) {
        
        DataPlugsService.getApplicationTokenFor(serviceName: "Twitter", resource: "https://twitter-plug.hubofallthings.com", succesfulCallBack: successful, failCallBack: failed)
    }
    
    // MARK: - Remove diplicates
    
    /**
     Removes duplicates from a json file and returns the corresponding objects
     
     - parameter array: The JSON array
     - returns: An array of TwitterSocialFeedObject
     */
    class func removeDuplicatesFrom(array: [JSON]) -> [TwitterSocialFeedObject] {
        
        // the array to return
        var arrayToReturn: [TwitterSocialFeedObject] = []
        
        // go through each dictionary object in the array
        for dictionary in array {
            
            // transform it to an TwitterSocialFeedObject
            let object = TwitterSocialFeedObject(from: dictionary.dictionaryValue)
            
            // check if the arrayToReturn it contains that value and if not add it
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
    
    /**
     Removes duplicates from an array of FacebookSocialFeedObject and returns the corresponding objects in an array
     
     - parameter array: The FacebookSocialFeedObject array
     - returns: An array of FacebookSocialFeedObject
     */
    class func removeDuplicatesFrom(array: [TwitterSocialFeedObject]) -> [TwitterSocialFeedObject] {
        
        // the array to return
        var arrayToReturn: [TwitterSocialFeedObject] = []
        
        // go through each tweet object in the array
        for tweet in array {
            
            // check if the arrayToReturn it contains that value and if not add it
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
