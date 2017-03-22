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

/// The twitter data plug service class
public class HATTwitterService: NSObject {
    
    // MARK: - Check twitter plug
    
    /**
     Fetched the user's posts from twitter
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    private class func checkTwitterDataPlugTable(authToken: String, userDomain: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> Void {
        
        HATAccountService.checkHatTableExists(userDomain: userDomain,
                                              tableName: Twitter.tableName,
                                              sourceName: Twitter.sourceName,
                                              authToken: authToken,
                                              successCallback: getTweets(token: authToken, userDomain: userDomain, parameters: parameters, success: success),
                                              errorCallback: {(error: HATTableError) -> Void in return})
    }
    
    /**
     Checks if twitter plug is active
     
     - parameter token: The authorisation token to authenticate with the hat
     - parameter successful: An @escaping (Void) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    public class func isTwitterDataPlugActive(token: String, successful: @escaping (Bool) -> Void, failed: @escaping (TwitterError) -> Void) {
        
        // construct the url, set parameters and headers for the request
        let url = Twitter.statusURL
        let parameters: Dictionary<String, String> = [:]
        let headers = [RequestHeaders.xAuthToken : token]
        
        // make the request
        ΗΑΤNetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion: {(r : ΗΑΤNetworkHelper.ResultType) -> Void in
            
            // act upon response
            switch r {
                
            case .isSuccess(_, let statusCode, _):
                
                if statusCode == 200 {
                    
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
    
    // MARK: - Get tweets
    
    /**
     Gets tweets from database
     
     - parameter authToken: The authorisation token to authenticate with the hat
     - parameter parameters: The parameters to use in the request
     - parameter success: An @escaping (_ array: [JSON]) -> Void) method executed on a successful response
     */
    private class func getTweets(token: String, userDomain: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON]) -> Void) -> (_ tableID: NSNumber) -> Void  {
        
        return {(tableID: NSNumber) -> Void in
            
            HATAccountService.getHatTableValues(token: token, userDomain: userDomain, tableID: tableID, parameters: parameters, successCallback: success, errorCallback: {(error: HATTableError) -> Void in return})
        }
    }
    
    // MARK: - Get application token for twitter
    
    /**
     Gets application token for twitter
     
     - parameter successful: An @escaping (String) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    public class func getAppTokenForTwitter(userDomain: String, token: String, successful: @escaping (String) -> Void, failed: @escaping (JSONParsingError) -> Void) {
        
        HATService.getApplicationTokenFor(serviceName: Twitter.serviceName, userDomain: userDomain, token: token, resource: Twitter.dataPlugURL, succesfulCallBack: successful, failCallBack: failed)
    }
    
    // MARK: - Remove diplicates
    
    /**
     Removes duplicates from a json file and returns the corresponding objects
     
     - parameter array: The JSON array
     - returns: An array of TwitterSocialFeedObject
     */
    public class func removeDuplicatesFrom(array: [JSON]) -> [HATTwitterSocialFeedObject] {
        
        // the array to return
        var arrayToReturn: [HATTwitterSocialFeedObject] = []
        
        // go through each dictionary object in the array
        for dictionary in array {
            
            // transform it to an TwitterSocialFeedObject
            let object = HATTwitterSocialFeedObject(from: dictionary.dictionaryValue)
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(tweet: HATTwitterSocialFeedObject) -> Bool in
                
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
    public class func removeDuplicatesFrom(array: [HATTwitterSocialFeedObject]) -> [HATTwitterSocialFeedObject] {
        
        // the array to return
        var arrayToReturn: [HATTwitterSocialFeedObject] = []
        
        // go through each tweet object in the array
        for tweet in array {
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(tweeter: HATTwitterSocialFeedObject) -> Bool in
                
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
