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
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - returns: <#Returns#>
     */
    public class func searchFiles(userDomain: String, token: String, successCallback: @escaping ([FileUploadObject]) -> Void, errorCallBack: @escaping (HATError) -> Void) {
        
        let url: String = "https://" + userDomain + "/api/v2/files/search"
        let headers = ["X-Auth-Token" : token]
        HATNetworkHelper.AsynchronousRequest(url, method: .post, encoding: Alamofire.JSONEncoding.default, contentType: "application/json", parameters: ["source" : "iPhone", "name": ""], headers: headers, completion: {
            
            (r) -> Void in
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, let statusCode, let result):
                
                if isSuccess {
                    
                    var images: [FileUploadObject] = []
                    // reload table
                    for image in result.arrayValue {
                        
                        images.append(FileUploadObject(from: image.dictionaryValue))
                    }
                    
                    successCallback(images)
                } else {
                    
                    let message = "Server returned unexpected respone"
                    errorCallBack(.generalError(message, statusCode, nil))
                }
                
            case .error(let error, let statusCode):
                
                let message = "Server returned unexpected respone"
                errorCallBack(.generalError(message, statusCode, error))
                print("error res: \(error)")
            }
        })
    }
}
