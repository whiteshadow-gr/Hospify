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

// MARK: Class

public class HATFileService: NSObject {

    // MARK: - Functions
    
    /**
     Searches and returns the files we want
     
     - parameter token: The authorisation token to authenticate with the hat
     - parameter userDomain: The user's HAT domain
     - parameter status: The status of the file, Completed or Deleted. Default value is Completed
     - parameter successCallback: An @escaping ([FileUploadObject]) -> Void function to execute when the server has returned the files we were looking for
     - parameter errorCallBack: An @escaping (HATError) -> Void to execute when something went wrong
     */
    public class func searchFiles(userDomain: String, token: String, status: String? = "Completed", successCallback: @escaping ([FileUploadObject], String?) -> Void, errorCallBack: @escaping (HATError) -> Void) {
        
        let url: String = "https://" + userDomain + "/api/v2/files/search"
        let headers = ["X-Auth-Token" : token]
        HATNetworkHelper.AsynchronousRequest(url, method: .post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: ["source" : "iPhone", "name": "", "status" : ["status" : status!, "size" : 0]], headers: headers, completion: { (r) -> Void in
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, let statusCode, let result, let token):
                
                if isSuccess {
                    
                    var images: [FileUploadObject] = []
                    // reload table
                    for image in result.arrayValue {
                        
                        images.append(FileUploadObject(from: image.dictionaryValue))
                    }
                    
                    successCallback(images, token)
                } else {
                    
                    let message = "Server returned unexpected respone"
                    errorCallBack(.generalError(message, statusCode, nil))
                }
                
            case .error(let error, let statusCode):
                
                let message = "Server returned unexpected respone"
                errorCallBack(.generalError(message, statusCode, error))
            }
        })
    }
    
    /**
     Deletes a file, with the specified ID, from the server
     
     - parameter fileID: The ID of the file to delete
     - parameter token: The authorisation token to authenticate with the hat
     - parameter userDomain: The user's HAT domain
     - parameter successCallback: An @escaping (Bool) -> Void function to execute when the file has been deleted
     - parameter errorCallBack: An @escaping (HATError) -> Void to execute when something went wrong
     */
    public class func deleteFile(fileID: String, token: String, userDomain: String, successCallback: @escaping (Bool, String?) -> Void, errorCallBack: @escaping (HATError) -> Void) {
        
        let url: String = "https://" + userDomain + "/api/v2/files/file/" + fileID
        let headers = ["X-Auth-Token" : token]

        HATNetworkHelper.AsynchronousRequest(url, method: .delete, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: headers, completion: { (r) -> Void in
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, let statusCode, _, let token):
                
                if isSuccess {
                    
                    if statusCode == 200 {
                        
                        successCallback(true, token)
                    } else {
                        
                        let message = "Server returned unexpected respone"
                        errorCallBack(.generalError(message, statusCode, nil))
                    }
                } else {
                    
                    let message = "Server returned unexpected respone"
                    errorCallBack(.generalError(message, statusCode, nil))
                }
                
            case .error(let error, let statusCode):
                
                let message = "Server returned unexpected respone"
                errorCallBack(.generalError(message, statusCode, error))
            }
        })
    }
    
    /**
     Makes an already uploaded file public
     
     - parameter fileID: The ID of the file to change
     - parameter token: The authorisation token to authenticate with the hat
     - parameter userDomain: The user's HAT domain
     - parameter successCallback: An @escaping (Bool) -> Void function to execute when the file has been made public
     - parameter errorCallBack: An @escaping (HATError) -> Void to execute when something went wrong
     */
    public class func makeFilePublic(fileID: String, token: String, userDomain: String, successCallback: @escaping (Bool) -> Void, errorCallBack: @escaping (HATError) -> Void) {
        
        let url: String = "https://" + userDomain + "/api/v2/files/allowAccessPublic/" + fileID
        let headers = ["X-Auth-Token" : token]
        
        HATNetworkHelper.AsynchronousRequest(url, method: .delete, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: headers, completion: { (r) -> Void in
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, let statusCode, _, _):
                
                if isSuccess {
                    
                    if statusCode == 200 {
                        
                        successCallback(true)
                    } else {
                        
                        let message = "Server returned unexpected respone"
                        errorCallBack(.generalError(message, statusCode, nil))
                    }
                } else {
                    
                    let message = "Server returned unexpected respone"
                    errorCallBack(.generalError(message, statusCode, nil))
                }
                
            case .error(let error, let statusCode):
                
                let message = "Server returned unexpected respone"
                errorCallBack(.generalError(message, statusCode, error))
            }
        })
    }
    
    /**
     Makes an already uploaded file private
     
     - parameter fileID: The ID of the file to change
     - parameter token: The authorisation token to authenticate with the hat
     - parameter userDomain: The user's HAT domain
     - parameter successCallback: An @escaping (Bool) -> Void function to execute when the file has been made private
     - parameter errorCallBack: An @escaping (HATError) -> Void to execute when something went wrong
     */
    public class func makeFilePrivate(fileID: String, token: String, userDomain: String, successCallback: @escaping (Bool) -> Void, errorCallBack: @escaping (HATError) -> Void) {
        
        let url: String = "https://" + userDomain + "/api/v2/files/restrictAccessPublic/" + fileID
        let headers = ["X-Auth-Token" : token]
        
        HATNetworkHelper.AsynchronousRequest(url, method: .delete, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: headers, completion: { (r) -> Void in
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, let statusCode, _, _):
                
                if isSuccess {
                    
                    if statusCode == 200 {
                        
                        successCallback(true)
                    } else {
                        
                        let message = "Server returned unexpected respone"
                        errorCallBack(.generalError(message, statusCode, nil))
                    }
                } else {
                    
                    let message = "Server returned unexpected respone"
                    errorCallBack(.generalError(message, statusCode, nil))
                }
                
            case .error(let error, let statusCode):
                
                let message = "Server returned unexpected respone"
                errorCallBack(.generalError(message, statusCode, error))
            }
        })
    }
    
}
