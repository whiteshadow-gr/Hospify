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

/// All network related methods
class NetworkHelper {
    
    // MARK: - Enums
    
    /**
     JSON Result from HTTP requests
     
     - IsSuccess: A tuple containing: isSuccess: Bool, statusCode: Int?, result: JSON
     - Error: A tuple containing: error: Error, statusCode: Int?
     */
    enum ResultType {
        
        /// when the result is success. A tuple containing: isSuccess: Bool, statusCode: Int?, result: JSON
        case isSuccess(isSuccess: Bool, statusCode: Int?, result: JSON)
        /// when the result is error. A tuple containing: error: Error, statusCode: Int?
        case error(error: Error, statusCode: Int?)
    }
    
    /**
     String Result from HTTP requests
     
     - IsSuccess: A tuple containing: isSuccess: Bool, statusCode: Int?, result: String
     - Error: A tuple containing: error: Error, statusCode: Int?
     */
    enum ResultTypeString {
        
        /// when the result is success. A tuple containing: isSuccess: Bool, statusCode: Int?, result: String
        case isSuccess(isSuccess: Bool, statusCode: Int?, result: String)
        /// when the result is error. A tuple containing: error: Error, statusCode: Int?
        case error(error: Error, statusCode: Int?)
    }
    
    // MARK: - Friendly exception message
    
    /**
     Gets the friendly message for an exception
     
     - parameter errorCode: The error code occured
     - parameter defaultMessage: The default message to show if the errorCode does not match
     
     - returns: A message as a String
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
    
    // MARK: - Query from string
    
    /**
     Gets a param value from a url
     
     - parameter url: The url to extract the parameters from
     - parameter param: The parameter
     
     - returns: String or nil if not found
     */
    class func GetQueryStringParameter(url: String?, param: String) -> String? {
        
        if let url = url, let urlComponents = NSURLComponents(string: url), let queryItems = (urlComponents.queryItems as [URLQueryItem]!) {
            
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        
        return nil
    }
    
    // MARK: - Construct request headers
    
    /**
     Construct the headers for the Requests
     
     - parameter xAuthToken: The xAuthToken String
     
     - returns: [String: String]
     */
    class func ConstructRequestHeaders(_ xAuthToken: String) -> [String: String] {
        
        return ["Accept": Constants.ContentType.JSON, "Content-Type": Constants.ContentType.JSON, "X-Auth-Token": xAuthToken]
    }
    
    // MARK: - Request methods
    
    /**
     Makes ansychronous JSON request
     Closure for caller to handle
     
     - parameter url: The URL to connect to
     - parameter method: The method to use in connecting with the URL
     - parameter encoding: The encoding to use in the request
     - parameter contentType: The content type of the request
     - parameter parameters: The parameters in the request
     - parameter headers: The headers in the request
     - parameter completion: The completion handler to execute upon completing the request
     */
    class func AsynchronousRequest(
        
            _ url: String,
            method: HTTPMethod,
            encoding: ParameterEncoding,
            contentType: String,
            parameters: Dictionary<String, Any>,
            headers: Dictionary<String, String>,
            completion: @escaping (_ r: NetworkHelper.ResultType) -> Void) -> Void {
        
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
                    
                    let headers = response.response?.allHeaderFields
                    if let tokenHeader = headers?["X-Auth-Token"] as? String {
                        
                        let result = AuthenticationHelper.decodeToken(token: tokenHeader, networkResponse: "")
                        if result.message == "refreshToken" && result.scope == "owner" {
                            
                            _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: tokenHeader)
                        }
                    }
                    
                    // check if we have a value and return it
                    if let value = response.result.value {
                    
                        let json = JSON(value)
                        completion(NetworkHelper.ResultType.isSuccess(isSuccess: true, statusCode: response.response?.statusCode, result: json))
                    // else return isSuccess: false and nil for value
                    } else {
                        
                        completion(NetworkHelper.ResultType.isSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                    
                // in case of failure return the error but check for internet connection or unauthorised status and let the user know
                case .failure(let error):
                    
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        
                        NotificationCenter.default.post(name: NSNotification.Name("NetworkMessage"), object: "The Internet connection appears to be offline.")
                    } else if response.response?.statusCode == 401 {
                        
                         NotificationCenter.default.post(name: NSNotification.Name("NetworkMessage"), object: "Unauthorized. Please sign out and try again.")
                        _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "false")
                    }
                    
                    completion(NetworkHelper.ResultType.error(error: error, statusCode: response.response?.statusCode))
                }
        }
    }
    
    /**
     Makes ansychronous string request
     Closure for caller to handle
     
     - parameter url: The URL to connect to
     - parameter method: The method to use in connecting with the URL
     - parameter encoding: The encoding to use in the request
     - parameter contentType: The content type of the request
     - parameter parameters: The parameters in the request
     - parameter headers: The headers in the request
     - parameter completion: The completion handler to execute upon completing the request
     */
    class func AsynchronousStringRequest(
        
        _ url: String,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        contentType: String,
        parameters: Dictionary<String, Any>,
        headers: Dictionary<String, String>,
        completion: @escaping (_ r: NetworkHelper.ResultTypeString) -> Void) -> Void {
        
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
                    
                    let headers = response.response?.allHeaderFields
                    if let tokenHeader = headers?["X-Auth-Token"] as? String {
                        
                        let result = AuthenticationHelper.decodeToken(token: tokenHeader, networkResponse: "")
                        if result.message == "refreshToken" && result.scope == "owner" {
                            
                            _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: tokenHeader)
                        }
                    }
                    
                    // check if we have a value and return it
                    if let value = response.result.value {
                        
                        completion(NetworkHelper.ResultTypeString.isSuccess(isSuccess: true, statusCode: response.response?.statusCode, result: value))
                    // else return isSuccess: false and nil for value
                    } else {
                        
                        completion(NetworkHelper.ResultTypeString.isSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                // return the error
                case .failure(let error):
                    
                    completion(NetworkHelper.ResultTypeString.error(error: error, statusCode: response.response?.statusCode))
                }
        }
    }
    
    /**
     Makes ansychronous data request
     used to POST data TO HAT
     Closure for caller to handle
     
     - parameter url: The URL to connect to
     - parameter method: The method to use in connecting with the URL
     - parameter encoding: The encoding to use in the request
     - parameter contentType: The content type of the request
     - parameter parameters: The parameters in the request
     - parameter headers: The headers in the request
     - parameter userHATAccessToken: The HAT access token
     - parameter completion: The completion handler to execute upon completing the request
     */
    class func AsynchronousRequestData(
        
        _ url: String,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        contentType: String,
        parameters: [AnyObject],
        headers: Dictionary<String, String>,
        userHATAccessToken: String,
        completion: @escaping (_ r: NetworkHelper.ResultType) -> Void) -> Void {
        
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
                    
                    let headers = response.response?.allHeaderFields
                    if let tokenHeader = headers?["X-Auth-Token"] as? String {
                        
                        let result = AuthenticationHelper.decodeToken(token: tokenHeader, networkResponse: "")
                        if result.message == "refreshToken" && result.scope == "owner" {
                            
                            _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: tokenHeader)
                        }
                    }
                    
                    // check if we have a value and return it
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        completion(NetworkHelper.ResultType.isSuccess(isSuccess: true, statusCode: response.response!.statusCode, result: json))
                    // else return isSuccess: false and nil for value
                    } else {
                        
                        completion(NetworkHelper.ResultType.isSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                // return the error
                case .failure(let error):
                    
                    completion(NetworkHelper.ResultType.error(error: error, statusCode: response.response?.statusCode))
                }
        }
    }
}
