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
import Crashlytics

// MARK: Struct

/// A class about the methods concerning the HAT
struct Service {
    
    // MARK: - Get available HAT providers

    /**
     Fetches the available HAT providers
     */
    static func getAvailableHATProviders(successCompletion: @escaping ([ProviderObject]) -> Void) {
        
        let url = "https://hatters.hubofallthings.com/api/products/hat"
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: [:], headers: [:], completion: {(r: NetworkHelper.ResultType) -> Void in
        
            switch r {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    let resultArray = result.arrayValue
                    var arrayToSendBack: [ProviderObject] = []
                    for item in resultArray {
                        
                        arrayToSendBack.append(ProviderObject(from: item.dictionaryValue))
                    }
                        
                    successCompletion(arrayToSendBack)
                }
            }
        })
    }
    
    // MARK: - Get system status
    
    /**
     Fetches the available HAT providers
     */
    static func getSystemStatus(userDomain: String, authToken: String, completion: @escaping ([SystemStatusObject]) -> Void) {
        
        let url = "https://" + userDomain + "/api/v2/system/status"
        let headers = ["X-Auth-Token" : authToken]
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: [:], headers: headers, completion: {(r: NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    let resultArray = result.arrayValue
                    var arrayToSendBack: [SystemStatusObject] = []
                    for item in resultArray {
                        
                        arrayToSendBack.append(SystemStatusObject(from: item.dictionaryValue))
                    }
                    
                    completion(arrayToSendBack)
                }
            }
        })
    }
}
