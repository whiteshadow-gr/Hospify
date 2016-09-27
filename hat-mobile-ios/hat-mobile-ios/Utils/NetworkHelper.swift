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
            url: String,
            method: Alamofire.Method,
            encoding: Alamofire.ParameterEncoding,
            contentType: String,
            parameters: Dictionary<String, AnyObject>,
            headers: Dictionary<String, String>,
            completion: (r: Helper.ResultType) -> Bool) -> Void {
        
        let manager = Alamofire.Manager.sharedInstance
        
        // do a post
        manager.request(
            method, /* GET, POST, etc*/
            url, /* request url */
            headers: headers, /* request header */
            parameters: parameters, /* parameters to POST*/
            encoding: encoding) /* encoding type, JSON, URLEncoded, etc*/
            .validate(statusCode: 200..<300)
            .validate(contentType: [contentType])
            .responseJSON { response in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                switch response.result {
                case .Success(_):
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        completion(r: Helper.ResultType.IsSuccess(isSuccess: true, statusCode: response.response?.statusCode, result: json))
                    }else{
                        completion(r: Helper.ResultType.IsSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                    
                    
                case .Failure(let error):
                    completion(r: Helper.ResultType.Error(error: error, statusCode: response.response?.statusCode))
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
        url: String,
        method: Alamofire.Method,
        encoding: Alamofire.ParameterEncoding,
        contentType: String,
        parameters: [AnyObject],
        headers: Dictionary<String, String>,
        userHATAccessToken: String,
        completion: (r: Helper.ResultType) -> Bool) -> Void {
        
        
        let manager = Alamofire.Manager.sharedInstance

        let nsURL = NSURL(string: url)

        let request = NSMutableURLRequest(URL: nsURL!)
        request.HTTPMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        
        manager.request(request)
            .responseJSON { response in
                switch response.result {
                case .Success(_):
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        completion(r: Helper.ResultType.IsSuccess(isSuccess: true, statusCode: response.response!.statusCode, result: json))
                    }else{
                        completion(r: Helper.ResultType.IsSuccess(isSuccess: false, statusCode: response.response?.statusCode, result: ""))
                    }
                    
                    
                case .Failure(let error):
                    completion(r: Helper.ResultType.Error(error: error, statusCode: response.response?.statusCode))
                }
        }

    }

    
}
