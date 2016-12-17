/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import Alamofire
import SwiftyJSON

/// All network requests for through here
class NetworkHelper {
    
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
                        
                        NotificationCenter.default.post(name: NSNotification.Name("NoInternet"), object: nil)
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
