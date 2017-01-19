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

/// All network requests for through here
class NetworkHelper {
    
    /**
     Gets the friendly message for an exception
     
     - returns: String
     */
    class func ExceptionFriendlyMessage(_ errorCode: Int!, defaultMessage: String) -> String {
        
        if let errorCodeCheck: Int = errorCode {
            
            switch errorCodeCheck {
                
            case 401:
                
                return NSLocalizedString("exception_401", comment: "")
            case 400:
                
                return NSLocalizedString("exception_400", comment: "")
            case 500:
                
                return NSLocalizedString("exception_500", comment: "")
            case 504:
                
                return NSLocalizedString("exception_504", comment: "")
            default:
                
                return defaultMessage
            }
        } else {
            
            return defaultMessage
        }
    }
    
    /**
     Gets a param value from a url
     
     - returns: String or nil
     */
    class func GetQueryStringParameter(url: String?, param: String) -> String? {
        
        if let url = url, let urlComponents = NSURLComponents(string: url), let queryItems = (urlComponents.queryItems as [URLQueryItem]!) {
            
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        return nil
    }
    
    /**
     Construct the headers for the Requests
     
     - parameter xAuthToken: The xAuthToken String
     - returns: [String: String]
     */
    class func ConstructRequestHeaders(_ xAuthToken: String) -> [String: String] {
        
        let headers = ["Accept": Constants.ContentType.JSON, "Content-Type": Constants.ContentType.JSON, "X-Auth-Token": xAuthToken]
        
        return headers
    }
    
    /**
     Makes ansychronous network call
     Closure for caller to handle
     
     - parameter url:         <#url description#>
     - parameter method:      <#method description#>
     - parameter encoding:    <#encoding description#>
     - parameter contentType: <#contentType description#>
     - parameter parameters:  <#parameters description#>
     - parameter headers:     <#headers description#>
     - parameter completion:  <#completion description#>
     */
    class func AsynchronousRequest(
        
            _ url: String,
            method: HTTPMethod,
            encoding: ParameterEncoding,
            contentType: String,
            parameters: Dictionary<String, Any>,
            headers: Dictionary<String, String>,
            completion: @escaping (_ r: Helper.ResultType) -> Void) -> Void {
        
        // do a post
        Alamofire.request(
            url, /* request url */
            method: method, /* GET, POST, etc*/
            parameters: parameters, /* parameters to POST*/
            encoding: encoding, /* encoding type, JSON, URLEncoded, etc*/
            headers: headers /* request header */
            )
            .validate(statusCode: 200..<300)
            .validate(contentType: [contentType])
            .responseJSON { response in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                switch response.result {
                case .success(_):
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        completion(
                            Helper.ResultType.isSuccess(isSuccess: true, statusCode: response.response?.statusCode, result: json)
                        )
                    } else {
                        
                        completion(Helper.ResultType.isSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                    
                case .failure(let error):
                    
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        
                        NotificationCenter.default.post(name: NSNotification.Name("NetworkMessage"), object: "The Internet connection appears to be offline.")
                    } else if response.response?.statusCode == 401 {
                        
                         NotificationCenter.default.post(name: NSNotification.Name("NetworkMessage"), object: "Unauthorized. Please sign out and try again.")
                    }
                    completion(Helper.ResultType.error(error: error, statusCode: response.response?.statusCode))
                }
        }
    }
    
    /**
     Makes ansychronous network call
     Closure for caller to handle
     
     - parameter url:         <#url description#>
     - parameter method:      <#method description#>
     - parameter encoding:    <#encoding description#>
     - parameter contentType: <#contentType description#>
     - parameter parameters:  <#parameters description#>
     - parameter headers:     <#headers description#>
     - parameter completion:  <#completion description#>
     */
    class func AsynchronousStringRequest(
        
        _ url: String,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        contentType: String,
        parameters: Dictionary<String, Any>,
        headers: Dictionary<String, String>,
        completion: @escaping (_ r: Helper.ResultTypeString) -> Void) -> Void {
        
        // do a post
        Alamofire.request(
            url, /* request url */
            method: method, /* GET, POST, etc*/
            parameters: parameters, /* parameters to POST*/
            encoding: encoding, /* encoding type, JSON, URLEncoded, etc*/
            headers: headers /* request header */
            )
            .validate(statusCode: 200..<300)
            .validate(contentType: [contentType])
            .responseString { response in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                switch response.result {
                case .success(_):
                    
                    if let value = response.result.value {
                        
                        completion(Helper.ResultTypeString.isSuccess(isSuccess: true, statusCode: response.response?.statusCode, result: value))
                    } else {
                        
                        completion(Helper.ResultTypeString.isSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                case .failure(let error):
                    
                    completion(Helper.ResultTypeString.error(error: error, statusCode: response.response?.statusCode))
                }
        }
    }
    
    /**
     used to POST data TO HAT
     Closure for caller to handle
     
     - parameter url:                <#url description#>
     - parameter method:             <#method description#>
     - parameter encoding:           <#encoding description#>
     - parameter contentType:        <#contentType description#>
     - parameter parameters:         <#parameters description#>
     - parameter headers:            <#headers description#>
     - parameter userHATAccessToken: <#userHATAccessToken description#>
     - parameter completion:         <#completion description#>
     */
    class func AsynchronousRequestData(
        
        _ url: String,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        contentType: String,
        parameters: [AnyObject],
        headers: Dictionary<String, String>,
        userHATAccessToken: String,
        completion: @escaping (_ r: Helper.ResultType) -> Void) -> Void {
        
        let nsURL = NSURL(string: url)

        let request = NSMutableURLRequest(url: nsURL! as URL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let url = URL(string: url)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        completion(Helper.ResultType.isSuccess(isSuccess: true, statusCode: response.response!.statusCode, result: json))
                    } else {
                        
                        completion(Helper.ResultType.isSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                    
                case .failure(let error):
                    
                    completion(Helper.ResultType.error(error: error, statusCode: response.response?.statusCode))
                }
        }
    }
}
